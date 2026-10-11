import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'data/local_store.dart';
import 'data/market_repository.dart';
import 'domain/models.dart';
class WorkspaceController extends GetxController with WidgetsBindingObserver {
  final KeyValueStore store; final MarketRepository repository;
  final workspace=const Workspace().obs;
  final coins=<Coin>[].obs,quotes=<String,Coin>{}.obs;
  final global=<String,dynamic>{}.obs,research=<ResearchItem>[].obs,providers=<String,String>{}.obs;
  final loading=false.obs,researchLoading=false.obs,cached=false.obs;
  final error=''.obs,researchError=''.obs,globalError=''.obs;
  final fetchedAt=Rxn<DateTime>(); final tab=0.obs;
  Timer? _timer; Future<void> _writes=Future.value(); bool storageDamaged=false;
  int _generation=0;
  WorkspaceController(this.store,this.repository);
  @override void onInit() {
    super.onInit(); WidgetsBinding.instance.addObserver(this);
    try {final raw=store.read('workspace_v2');if(raw!=null) workspace.value=Workspace.fromJson(Map<String,dynamic>.from(raw));}
    catch(_) {storageDamaged=true;error.value='Stored workspace could not be read. Export recovery data or restore a backup in Settings.';}
  }
  @override void onReady() {super.onReady();refreshMarket();loadResearch();_startTimer();}
  void _startTimer() {_timer?.cancel();_timer=Timer.periodic(const Duration(minutes:2),(_)=>refreshMarket());}
  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state==AppLifecycleState.resumed) {refreshMarket();_startTimer();} else {_timer?.cancel();}
  }
  Future<void> change(Workspace Function(Workspace) update,{bool recover=false}) {
    final next=_writes.catchError((Object _){}).then((_) async {
      if(storageDamaged&&!recover) throw const FormatException('Restore or reset the unreadable workspace before editing.');
      final value=update(workspace.value); Workspace.fromJson(value.toJson());
      await store.write('workspace_v2',value.toJson()); workspace.value=value;
      if(recover) storageDamaged=false;
    });
    _writes=next;return next;
  }
  Future<void> toggleWatch(String id) async {
    await change((w) {final list=[...w.watchlist];list.contains(id)?list.remove(id):list.add(id);
      if(list.length>100) throw const FormatException('Watchlist limit is 100 coins.');return w.copy(watchlist:list);});
    await refreshMarket();
  }
  Future<void> addTrade(Trade t)=>change((w) {
    if(t.time.isAfter(DateTime.now().add(const Duration(minutes:1)))) throw const FormatException('Transaction dates cannot be in the future.');
    final trades=[...w.trades,t];calculatePositions(trades);return w.copy(trades:trades);
  });
  Future<void> deleteTrade(String id)=>change((w) {final ts=w.trades.where((t)=>t.id!=id).toList();
    calculatePositions(ts);return w.copy(trades:ts);});
  Map<String,Position> get positions=>calculatePositions(workspace.value.trades);
  Map<String,Position> get openPositions=>Map.fromEntries(positions.entries.where((e)=>e.value.quantity>0));
  double? get portfolioValue {
    double total=0;
    for(final e in openPositions.entries) {final price=quotes[e.key]?.price;if(price==null) return null;total+=price*e.value.quantity;}
    return total.isFinite?total:null;
  }
  bool get portfolioFresh=>openPositions.keys.every((id)=>quotes[id]?.freshAt(DateTime.now())??false);
  double get totalCost=>positions.values.fold(0,(a,p)=>a+p.cost);
  double get realized=>positions.values.fold(0,(a,p)=>a+p.realized);
  Future<void> addAlert(PriceAlert a) async {await change((w)=>w.copy(alerts:[...w.alerts,a]));await refreshMarket();}
  Future<void> saveResearch(ResearchItem item)=>change((w) => w.copy(saved:w.saved.any((x)=>x.id==item.id)?
    w.saved.where((x)=>x.id!=item.id).toList():[item,...w.saved]));
  Future<void> refreshMarket({bool force=false}) async {
    if(loading.value) return;
    loading.value=true;final generation=_generation;
    try {
      final snapshot=await repository.markets(force:force);
      if(generation!=_generation) return;
      coins.assignAll(snapshot.coins);quotes.addAll({for(final c in snapshot.coins)c.id:c});
      fetchedAt.value=snapshot.fetchedAt;cached.value=snapshot.cached;
      if(!storageDamaged) error.value=snapshot.warning??'';
      final needed={...workspace.value.watchlist,...openPositions.keys,
        ...workspace.value.alerts.where((a)=>a.triggeredAt==null).map((a)=>a.coinId)}.difference(snapshot.coins.map((c)=>c.id).toSet()).toList();
      for(var i=0;i<needed.length;i+=100) {
        final extra=await repository.markets(ids:needed.skip(i).take(100).toList(),force:force);
        if(generation!=_generation) return;
        quotes.addAll({for(final c in extra.coins)c.id:c});
        if(extra.warning!=null) error.value=extra.warning!;
      }
      final now=DateTime.now().toUtc();
      if(workspace.value.alerts.any((a)=>quotes[a.coinId]!=null&&a.matches(quotes[a.coinId]!,now))) {
        await change((w)=>w.copy(alerts:w.alerts.map((a)=>quotes[a.coinId]!=null&&a.matches(quotes[a.coinId]!,now)?a.copy(triggeredAt:now):a).toList()));
      }
    } catch(e) {if(!storageDamaged) error.value=friendlyError(e);}
    finally {loading.value=false; if(generation!=_generation) {unawaited(refreshMarket(force:true));}}
    try {global.assignAll(await repository.global());globalError.value='';}
    catch(e) {global.clear();globalError.value=friendlyError(e);}
  }
  Future<void> loadResearch() async {
    if(researchLoading.value) return;researchLoading.value=true;
    try {final r=await repository.research();research.assignAll((r['items'] as List).map((j)=>ResearchItem.fromJson(Map<String,dynamic>.from(j))));
      providers.assignAll(Map<String,String>.from(r['providers']));researchError.value='';}
    catch(e) {researchError.value=friendlyError(e);}
    finally {researchLoading.value=false;}
  }
  Future<void> restore(Workspace w) async {
    await change((_)=>w,recover:true);_generation++;quotes.clear();error.value='';
    await refreshMarket(force:true);
  }
  String export()=>storageDamaged?store.read('workspace_v2').toString():workspace.value.export();
  @override void onClose() {_timer?.cancel();WidgetsBinding.instance.removeObserver(this);repository.close();super.onClose();}
}
