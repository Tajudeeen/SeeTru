import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models.dart';
import '../data/market_repository.dart';
import '../workspace_controller.dart';
import 'components.dart';
import 'detail.dart';
void openCoin(Coin coin)=>Get.to(()=>CoinDetailPage(coin));
Future<Coin?> showCoinSearch(BuildContext context,{bool pick=false}) async {
  final coin=await showModalBottomSheet<Coin>(context:context,isScrollControlled:true,useSafeArea:true,
    builder:(_)=>const _SearchSheet());
  if(coin!=null&&!pick) openCoin(coin);return coin;
}
class MarketsPage extends StatefulWidget {
  final bool watchlist;const MarketsPage({super.key,this.watchlist=false});
  @override State<MarketsPage> createState()=>_MarketsPageState();
}
class _MarketsPageState extends State<MarketsPage> {
  String query='',sort='Market cap';
  @override Widget build(BuildContext context) {final c=Get.find<WorkspaceController>();return Obx(() {
    final list=widget.watchlist?c.workspace.value.watchlist.map((id)=>c.quotes[id]??Coin(id:id,name:id,symbol:id)).toList():c.coins.toList();
    list.removeWhere((coin)=>!('${coin.name} ${coin.symbol}'.toLowerCase().contains(query.toLowerCase())));
    if(sort=='Gainers') {list.sort((a,b)=>(b.change??-double.infinity).compareTo(a.change??-double.infinity));}
    if(sort=='Name') {list.sort((a,b)=>a.name.compareTo(b.name));}
    return PageBody(refresh:()=>c.refreshMarket(force:true),children:[
      TitleBlock(widget.watchlist?'Your watchlist':'The market, in focus',widget.watchlist?'Follow the assets that matter to you.':'Live prices. Clear sources. Your own perspective.',
        trailing:IconButton(tooltip:'Refresh market',onPressed:()=>c.refreshMarket(force:true),icon:const Icon(Icons.refresh))),
      if(!widget.watchlist) const _Overview(),
      if(c.error.value.isNotEmpty) StatusNote(c.error.value),
      if(c.loading.value) const LinearProgressIndicator(),
      Text('${c.cached.value?'Cached':'CoinGecko'} snapshot · ${stamp(c.fetchedAt.value)} · USD'),
      Wrap(spacing:12,runSpacing:12,children:[SizedBox(width:280,child:TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Filter loaded coins'),
        onChanged:(v)=>setState(()=>query=v))),DropdownButton<String>(value:sort,items:['Market cap','Gainers','Name'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
        onChanged:(v)=>setState(()=>sort=v!)),TextButton.icon(onPressed:()=>showCoinSearch(context),icon:const Icon(Icons.travel_explore),label:const Text('Search all coins'))]),
      if(list.isEmpty&&!c.loading.value) EmptyState(widget.watchlist?'Build your watchlist':'No coins to show',widget.watchlist?
        'Tap a star in Markets, or search for a coin.':'Refresh or change your filter. Provider errors appear above.'),
      if(list.isNotEmpty) Panel(padding:const EdgeInsets.all(8),child:Column(children:list.map((coin)=>CoinRow(coin,onTap:()=>openCoin(coin),
        trailing:IconButton(tooltip:c.workspace.value.watchlist.contains(coin.id)?'Remove from watchlist':'Add to watchlist',
          onPressed:()=>action(()=>c.toggleWatch(coin.id)),icon:Icon(c.workspace.value.watchlist.contains(coin.id)?Icons.star:Icons.star_outline,color:accent)))).toList()))
    ]);
  });}
}
class _Overview extends StatelessWidget {
  const _Overview();
  @override Widget build(BuildContext context) {final c=Get.find<WorkspaceController>();return Obx(()=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Wrap(spacing:16,runSpacing:16,children:[
      _Metric('Global market cap',money(number(c.global['total_market_cap']?['usd']))),
      _Metric('24h volume',money(number(c.global['total_volume']?['usd']))),
      _Metric('Bitcoin dominance',c.global['market_cap_percentage']?['btc']==null?'Unavailable':'${number(c.global['market_cap_percentage']['btc'])?.toStringAsFixed(1)}%')]),
    if(c.globalError.value.isNotEmpty)...[const SizedBox(height:12),Text('Global summary: ${c.globalError.value}')]
  ]));}
}
class _Metric extends StatelessWidget {
  final String label,value;const _Metric(this.label,this.value);
  @override Widget build(BuildContext context)=>SizedBox(width:280,child:Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(label),const SizedBox(height:12),Text(value,style:Theme.of(context).textTheme.titleLarge)])));
}
class _SearchSheet extends StatefulWidget {
  const _SearchSheet();@override State<_SearchSheet> createState()=>_SearchSheetState();
}
class _SearchSheetState extends State<_SearchSheet> {
  Timer? timer;int generation=0;bool loading=false;String error='';List<Coin> results=[];
  void search(String q) {
    timer?.cancel();final token=++generation;
    if(q.trim().isEmpty) {setState(()=>results=[]);return;}
    timer=Timer(const Duration(milliseconds:400),() async {
      setState(() {loading=true;error='';});
      try {final list=await Get.find<WorkspaceController>().repository.search(q.trim());
        if(mounted&&token==generation) setState(()=>results=list);}
      catch(e) {if(mounted&&token==generation) setState(()=>error=friendlyError(e));}
      finally {if(mounted&&token==generation) setState(()=>loading=false);}
    });
  }
  @override void dispose() {timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>SizedBox(height:MediaQuery.sizeOf(context).height*.8,child:Padding(padding:const EdgeInsets.all(24),
    child:Column(children:[TextField(autofocus:true,decoration:const InputDecoration(labelText:'Search CoinGecko',prefixIcon:Icon(Icons.search)),onChanged:search),
      const SizedBox(height:16),if(loading) const LinearProgressIndicator(),if(error.isNotEmpty) Text(error),
      Expanded(child:ListView(children:results.map((c)=>ListTile(leading:CoinAvatar(c),title:Text(c.name),subtitle:Text('${c.symbol.toUpperCase()} · ${c.id}'),
        onTap:()=>Navigator.pop(context,c))).toList()))])));
}
