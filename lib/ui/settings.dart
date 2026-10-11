import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../domain/models.dart';
import '../data/account_service.dart';
import '../workspace_controller.dart';
import 'components.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WorkspaceController>(),
        account = Get.find<AccountService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(
        () => PageBody(
          children: [
            const TitleBlock(
              'Your workspace',
              'Personal settings, accounts and data ownership.',
            ),
            Panel(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Display name'),
                    subtitle: Text(
                      c.workspace.value.name.isEmpty
                          ? 'Local workspace'
                          : c.workspace.value.name,
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _name(context, c),
                  ),
                  SwitchListTile(
                    title: const Text('Dark appearance'),
                    value: c.workspace.value.dark,
                    onChanged: (v) =>
                        action(() => c.change((w) => w.copy(dark: v))),
                  ),
                  SwitchListTile(
                    title: const Text('Hide portfolio balances'),
                    value: c.workspace.value.hideBalance,
                    onChanged: (v) =>
                        action(() => c.change((w) => w.copy(hideBalance: v))),
                  ),
                  const ListTile(
                    title: Text('Quote currency'),
                    subtitle: Text('USD'),
                  ),
                ],
              ),
            ),
            const TitleBlock(
              'Account & backup',
              'Your local workspace works without signing in.',
            ),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!account.available)
                    Text(
                      account.issue ??
                          'Firebase is not configured. Set the client configuration to enable email accounts and private cloud backups.',
                    ),
                  if (account.available && account.user.value == null)
                    FilledButton(
                      onPressed: () => _auth(context, account),
                      child: const Text('Sign in or create account'),
                    ),
                  if (account.available && account.user.value != null) ...[
                    Text(account.user.value!.email ?? 'Signed in'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton(
                          onPressed: () => action(() async {
                            if (await confirm(
                              'Replace cloud backup?',
                              'This saves the current workspace to your private account backup.',
                            )) {
                              await account.upload(c.workspace.value);
                            }
                          }),
                          child: const Text('Save cloud backup'),
                        ),
                        OutlinedButton(
                          onPressed: () => action(() async {
                            final backup = await account.download();
                            if (await confirm(
                              'Restore cloud backup?',
                              'This replaces the local workspace. Export it first if you want to keep it.',
                            )) {
                              await c.restore(backup);
                            }
                          }),
                          child: const Text('Restore cloud backup'),
                        ),
                        TextButton(
                          onPressed: () => action(account.signOut),
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Cloud backup is manual. Signing in does not merge, upload or replace local data automatically.',
                  ),
                ],
              ),
            ),
            const TitleBlock(
              'Data & recovery',
              'Keep a copy before changing devices or clearing browser data.',
            ),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Watchlists, transaction history, alerts and saved notes are stored on this device. Local data and JSON backups are not encrypted.',
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _export(context, c),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Export JSON'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _restore(context, c),
                        icon: const Icon(Icons.upload_outlined),
                        label: const Text('Restore JSON'),
                      ),
                      TextButton(
                        onPressed: () => action(() async {
                          if (await confirm(
                            'Reset local workspace?',
                            'This permanently removes the local watchlist, trades, alerts and notes. Your cloud backup remains available.',
                          )) {
                            await c.restore(const Workspace(onboarded: true));
                          }
                        }),
                        child: const Text('Reset workspace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const TitleBlock(
              'Data sources',
              'Every view keeps its source and availability visible.',
            ),
            const StatusNote(
              'Markets: CoinGecko. Funding: CryptoRank. On-chain: Dune query results. Social: original X posts. Research integrations require a configured server and provider access.',
            ),
            const Text(
              'SeeTru 2.0 · Research and portfolio tracking. No trading execution or investment recommendations.',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _name(BuildContext context, WorkspaceController c) async {
    final input = TextEditingController(text: c.workspace.value.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(controller: input, maxLength: 80),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => action(() async {
              await c.change((w) => w.copy(name: input.text.trim()));
              if (context.mounted) Navigator.pop(context);
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    input.dispose();
  }

  Future<void> _export(BuildContext context, WorkspaceController c) async {
    final text = c.export();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workspace JSON'),
        content: SizedBox(
          width: 600,
          height: 350,
          child: SingleChildScrollView(child: SelectableText(text)),
        ),
        actions: [
          TextButton(
            onPressed: () => action(
              () => Clipboard.setData(ClipboardData(text: text)),
              success: 'Backup copied',
            ),
            child: const Text('Copy JSON'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WorkspaceController c) async {
    final input = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore workspace'),
        content: SizedBox(
          width: 550,
          child: TextField(
            controller: input,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: 'Paste a SeeTru version 2 JSON backup',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => action(() async {
              final backup = Workspace.parse(input.text);
              if (!await confirm(
                'Replace local workspace?',
                'This restores ${backup.trades.length} transactions, ${backup.watchlist.length} watched coins and ${backup.saved.length} notes.',
              )) {
                return;
              }
              await c.restore(backup);
              if (context.mounted) Navigator.pop(context);
            }),
            child: const Text('Validate & restore'),
          ),
        ],
      ),
    );
    input.dispose();
  }

  Future<void> _auth(BuildContext context, AccountService account) async {
    final email = TextEditingController(), password = TextEditingController();
    bool register = false, busy = false;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(register ? 'Create account' : 'Sign in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextButton(
                onPressed: () => setState(() => register = !register),
                child: Text(
                  register ? 'Already have an account?' : 'Create an account',
                ),
              ),
              if (!register)
                TextButton(
                  onPressed: () => action(
                    () => account.resetPassword(email.text),
                    success:
                        'If the address is registered, a reset email will be sent.',
                  ),
                  child: const Text('Reset password'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      setState(() => busy = true);
                      await action(() async {
                        await account.authenticate(
                          email.text,
                          password.text,
                          register: register,
                        );
                        if (context.mounted) Navigator.pop(context);
                      });
                      if (context.mounted) setState(() => busy = false);
                    },
              child: Text(
                busy
                    ? 'Please wait…'
                    : register
                    ? 'Create account'
                    : 'Sign in',
              ),
            ),
          ],
        ),
      ),
    );
    email.dispose();
    password.dispose();
  }
}
