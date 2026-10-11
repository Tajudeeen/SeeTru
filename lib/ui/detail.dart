import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models.dart';
import '../workspace_controller.dart';
import '../data/market_repository.dart';
import 'components.dart';
import 'portfolio.dart';
import 'alerts.dart';
class CoinDetailPage extends StatefulWidget {
  final Coin coin;const CoinDetailPage(this.coin,{super.key});
  @override State<CoinDetailPage> createState()=>_CoinDetailState();
}
class _CoinDetailState extends State<CoinDetailPage> {
  int days=7,generation=0;bool loading=true;String error='';List<PricePoint> points=[];
  final c=Get.find<WorkspaceController>();
  @override void initState() {super.initState();loadQuote();loadChart();}
  Future<void> loadQuote() async {
    try {final r=await c.repository.markets(ids:[widget.coin.id]);c.quotes.addAll({for(final x in r.coins)x.id:x});}
    catch(e) {if(mounted) setState(()=>error=friendlyError(e));}
  }
  Future<void> loadChart() async {
    final token=++generation;setState(() {loading=true;error='';points=[];});
    try {final p=await c.repository.chart(widget.coin.id,days);if(mounted&&token==generation) setState(()=>points=p);}
    catch(e) {if(mounted&&token==generation) setState(()=>error=friendlyError(e));}
    finally {if(mounted&&token==generation) setState(()=>loading=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.coin.name)),body:Obx(() {
    final coin=c.quotes[widget.coin.id]??widget.coin;
    return PageBody(children:[TitleBlock(coin.name,'${coin.symbol.toUpperCase()} · ${coin.id}',trailing:IconButton(
      tooltip:'Toggle watchlist',onPressed:()=>action(()=>c.toggleWatch(coin.id)),icon:Icon(c.workspace.value.watchlist.contains(coin.id)?Icons.star:Icons.star_outline,color:accent))),
      Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(money(coin.price),style:Theme.of(context).textTheme.headlineLarge),
        Text('${percent(coin.change)} in 24 hours',style:TextStyle(color:(coin.change??0)<0?Colors.redAccent:accent)),
        const SizedBox(height:8),Text('CoinGecko · Updated ${stamp(coin.updatedAt)} · USD'),const SizedBox(height:20),
        Wrap(spacing:8,children:[1,7,30,90,365].map((d)=>ChoiceChip(label:Text(d==365?'1Y':'${d}D'),selected:days==d,
          onSelected:(_){setState(()=>days=d);loadChart();})).toList()),const SizedBox(height:16),
        if(loading) const SizedBox(height:180,child:Center(child:CircularProgressIndicator()))
        else if(error.isNotEmpty) StatusNote(error)
        else if(points.length<2) const StatusNote('No chart observations were returned for this range.')
        else ...[SparkChart(points.map((p)=>p.value).toList(),height:240),Text('${stamp(points.first.time)} → ${stamp(points.last.time)}')]])),
      if(!coin.freshAt(DateTime.now())) const StatusNote('This quote is missing or stale. Refresh before using it to value a position.'),
      Wrap(spacing:16,runSpacing:16,children:[_stat('Market cap',money(coin.marketCap)),_stat('24h volume',money(coin.volume)),_stat('Rank',coin.rank?.toString()??'Unavailable')]),
      Wrap(spacing:12,runSpacing:12,children:[FilledButton.icon(onPressed:()=>showTradeEditor(context,coin:coin),icon:const Icon(Icons.add),label:const Text('Record trade')),
        OutlinedButton.icon(onPressed:()=>showAlertEditor(context,coin),icon:const Icon(Icons.notifications_none),label:const Text('Create alert')),
        TextButton(onPressed:()=>action(()=>openSource('https://www.coingecko.com/en/coins/${Uri.encodeComponent(coin.id)}')),child:const Text('View source'))])]);
  }));
  Widget _stat(String label,String value)=>SizedBox(width:250,child:Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label),const SizedBox(height:12),Text(value)])));
}
