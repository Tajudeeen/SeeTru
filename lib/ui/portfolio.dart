import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../domain/models.dart';
import '../workspace_controller.dart';
import 'components.dart';
import 'markets.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WorkspaceController>();
    return Obx(() {
      final w = c.workspace.value, positions = c.openPositions;
      final value = c.portfolioValue;
      String amount(double? n) => w.hideBalance ? '••••' : money(n);
      final trades = w.trades.toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      return PageBody(
        refresh: () => c.refreshMarket(force: true),
        children: [
          TitleBlock(
            'Your portfolio',
            'A personal ledger of the trades you record.',
            trailing: FilledButton.icon(
              onPressed: () => showTradeEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('Record trade'),
            ),
          ),
          if (trades.isEmpty)
            const EmptyState(
              'Start with your first trade',
              'Record a purchase to track your holdings, cost basis and performance. No wallet connection or account is required.',
            ),
          if (trades.isNotEmpty) ...[
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('TOTAL HOLDINGS / USD')),
                      IconButton(
                        tooltip: 'Hide balances',
                        onPressed: () => action(
                          () => c.change(
                            (w) => w.copy(hideBalance: !w.hideBalance),
                          ),
                        ),
                        icon: Icon(
                          w.hideBalance
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    amount(value),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _metric('Cost basis', amount(c.totalCost)),
                      _metric(
                        'Unrealized P/L',
                        amount(value == null ? null : value - c.totalCost),
                      ),
                      _metric('Realized P/L', amount(c.realized)),
                    ],
                  ),
                ],
              ),
            ),
            if (value == null)
              const StatusNote(
                'Some holdings have no available price. Total value and unrealized performance are unavailable.',
              )
            else if (!c.portfolioFresh)
              const StatusNote(
                'At least one holding uses a stale quote. This valuation is an estimate.',
              ),
            const TitleBlock(
              'Holdings',
              'Average cost includes purchase fees.',
            ),
            if (positions.isEmpty)
              const StatusNote('All recorded holdings have been sold.'),
            ...positions.entries.map((e) {
              final t = w.trades.firstWhere((t) => t.coinId == e.key),
                  coin =
                      c.quotes[e.key] ??
                      Coin(id: e.key, name: t.name, symbol: t.symbol);
              final current = coin.price == null
                  ? null
                  : coin.price! * e.value.quantity;
              return Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CoinRow(coin, onTap: () => openCoin(coin)),
                    const Divider(),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _metric(
                          'Quantity',
                          w.hideBalance
                              ? '••••'
                              : NumberFormat(
                                  '0.########',
                                ).format(e.value.quantity),
                        ),
                        _metric('Average cost', amount(e.value.averageCost)),
                        _metric('Value', amount(current)),
                        _metric(
                          'Allocation',
                          w.hideBalance
                              ? '••••'
                              : value != null && value > 0 && current != null
                              ? '${(current / value * 100).toStringAsFixed(1)}%'
                              : 'Unavailable',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const TitleBlock(
              'Transaction history',
              'Deleting a purchase is blocked when later sales depend on it.',
            ),
            ...trades.map(
              (t) => Panel(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.buy ? 'Buy' : 'Sell'} ${t.symbol.toUpperCase()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(stamp(t.time)),
                        Text(
                          w.hideBalance
                              ? '••••'
                              : '${t.quantity} × ${money(t.price)} · Fee ${money(t.fee)}',
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Delete transaction',
                      onPressed: () => action(() async {
                        if (await confirm(
                          'Delete transaction?',
                          'The remaining ledger will be validated before this change is saved.',
                        )) {
                          await c.deleteTrade(t.id);
                        }
                      }),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
    ],
  );
}

Future<void> showTradeEditor(BuildContext context, {Coin? coin}) async {
  final chosen = coin ?? await showCoinSearch(context, pick: true);
  if (chosen == null || !context.mounted) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TradeEditor(chosen),
  );
}

class _TradeEditor extends StatefulWidget {
  final Coin coin;
  const _TradeEditor(this.coin);
  @override
  State<_TradeEditor> createState() => _TradeEditorState();
}

class _TradeEditorState extends State<_TradeEditor> {
  final form = GlobalKey<FormState>(),
      quantity = TextEditingController(),
      price = TextEditingController(),
      fee = TextEditingController(text: '0');
  bool buy = true, saving = false;
  DateTime date = DateTime.now();
  @override
  void dispose() {
    quantity.dispose();
    price.dispose();
    fee.dispose();
    super.dispose();
  }

  String? validate(String? s, {bool zero = false}) {
    final n = double.tryParse(s ?? '');
    return n == null || !n.isFinite || (zero ? n < 0 : n <= 0)
        ? 'Enter a valid ${zero ? 'non-negative' : 'positive'} number'
        : null;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 24,
      right: 24,
      top: 24,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Record ${widget.coin.symbol.toUpperCase()} trade',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your actual execution price in USD. This records a transaction and does not execute an order.',
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Buy')),
                ButtonSegment(value: false, label: Text('Sell')),
              ],
              selected: {buy},
              onSelectionChanged: (v) => setState(() => buy = v.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: quantity,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Quantity'),
              validator: validate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Actual price / USD',
              ),
              validator: validate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: fee,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Fee / USD'),
              validator: (s) => validate(s, zero: true),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final day = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2009),
                  lastDate: DateTime.now(),
                );
                if (day == null || !context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(date),
                );
                if (time != null && mounted) {
                  setState(
                    () => date = DateTime(
                      day.year,
                      day.month,
                      day.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(stamp(date)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setState(() => saving = true);
                      await action(() async {
                        final t = Trade(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          coinId: widget.coin.id,
                          name: widget.coin.name,
                          symbol: widget.coin.symbol,
                          buy: buy,
                          quantity: double.parse(quantity.text),
                          price: double.parse(price.text),
                          fee: double.parse(fee.text),
                          time: date.toUtc(),
                        );
                        final c = Get.find<WorkspaceController>();
                        await c.addTrade(t);
                        if (context.mounted) Navigator.pop(context);
                        await c.refreshMarket();
                      }, success: 'Transaction saved');
                      if (mounted) setState(() => saving = false);
                    },
              child: Text(saving ? 'Saving…' : 'Save transaction'),
            ),
          ],
        ),
      ),
    ),
  );
}
