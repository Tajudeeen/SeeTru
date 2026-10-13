import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seetru/ui/app.dart';
import 'package:seetru/ui/markets.dart';
import 'package:seetru/ui/detail.dart';
import 'package:seetru/ui/alerts.dart';
import 'package:seetru/ui/settings.dart';
import 'package:seetru/ui/portfolio.dart';
import 'package:seetru/domain/models.dart';
import 'package:seetru/workspace_controller.dart';
import 'package:seetru/data/account_service.dart';
import 'helpers.dart';
const samples=[Coin(id:'bitcoin',name:'Bitcoin',symbol:'btc',price:100,change:2.4,marketCap:1000000,volume:25000,rank:1),
 Coin(id:'ethereum',name:'Ethereum',symbol:'eth',price:25,change:-1.8,marketCap:500000,volume:14000,rank:2),
 Coin(id:'solana',name:'Solana',symbol:'sol',price:5,change:4.6,marketCap:150000,volume:8000,rank:3)];
const observation=ResearchItem(id:'sample-round',category:'Funding',title:'Sample funding observation',body:'A sourced funding round appears here with its amount, investors and original reference. This item is sample data for the screen preview.',source:'CryptoRank',url:'https://cryptorank.io/funding-rounds');
class ScreensRepository extends FixtureRepository {
 ScreensRepository(super.store);
 @override Future<MarketSnapshot> markets({List<String> ids=const [],bool force=false}) async => MarketSnapshot(samples.map((s)=>Coin(id:s.id,name:s.name,symbol:s.symbol,price:s.price,change:s.change,marketCap:s.marketCap,volume:s.volume,rank:s.rank,updatedAt:DateTime.now())).toList(),DateTime.now());
 @override Future<List<Coin>> search(String q) async=>samples;
 @override Future<List<PricePoint>> chart(String id,int days) async=>List.generate(50,(i)=>PricePoint(DateTime(2026,10,13).subtract(Duration(hours:50-i)),80+i*.4+math.sin(i/4)*5));
 @override Future<Map<String,dynamic>> research() async=>{'items':[observation.toJson(),
 const ResearchItem(id:'sample-dune',category:'On-chain',title:'Sample on-chain observation',body:'Configured query results retain their observation date and source link. This is preview data.',source:'Dune',url:'https://dune.com').toJson(),
 const ResearchItem(id:'sample-social',category:'Social',title:'Sample original post',body:'Social items link back to the original post. No sentiment or engagement is invented.',source:'X',url:'https://x.com').toJson()],
 'providers':{'CryptoRank':'available','Dune':'available','X':'available'}};
}
void main() {
 testWidgets('capture every page and form', (tester) async {
   Directory('screenshots').createSync(recursive:true);
   await tester.runAsync(() async {
     for(final entry in {'Satoshi':'assets/fonts/Satoshi_Complete/Fonts/OTF/Satoshi-Regular.otf',
       'ClashDisplay':'assets/fonts/ClashDisplay_Complete/Fonts/OTF/ClashDisplay-Medium.otf','MaterialIcons':'fonts/MaterialIcons-Regular.otf'}.entries) {
       final font=FontLoader(entry.key)..addFont(rootBundle.load(entry.value));await font.load();
     }
   });
   tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
   final store=MemoryStore(),account=AccountService();final c=WorkspaceController(store,ScreensRepository(store));
   Get.put(c,permanent:true);Get.put(account,permanent:true);
   const key=ValueKey('capture');
   Future<void> settle() async {await tester.pumpAndSettle();}
   Future<void> save(String name) async {
     print('CAPTURE: $name');
     await settle();
     final boundary=tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
     await tester.runAsync(() async {
       final image=await boundary.toImage(pixelRatio:2);final data=await image.toByteData(format:ui.ImageByteFormat.png);
       await File('screenshots/$name.png').writeAsBytes(data!.buffer.asUint8List());image.dispose();
     });
   }
   Future<void> tap(String text) async {await tester.ensureVisible(find.text(text).first);await settle();await tester.tap(find.text(text).first);await settle();}
   Future<void> route(Widget page) async {Get.to(()=>page);await settle();}
   Future<void> back() async {Get.back();await settle();}
   try {
     await tester.pumpWidget(const RepaintBoundary(key:key,child:SeeTruApp()));await save('01-welcome');
     await c.change((w)=>w.copy(onboarded:true));await save('02-markets');
     c.tab.value=1;await save('03-watchlist-empty');
     await c.change((w)=>w.copy(watchlist:['bitcoin','ethereum','solana']));await save('04-watchlist');
     c.tab.value=2;await save('05-portfolio-empty');
     await c.change((w)=>w.copy(trades:[
       Trade(id:'buybtc',coinId:'bitcoin',name:'Bitcoin',symbol:'btc',buy:true,quantity:10,price:80,fee:4,time:DateTime(2026,10,1)),
       Trade(id:'buyeth',coinId:'ethereum',name:'Ethereum',symbol:'eth',buy:true,quantity:12,price:20,fee:2,time:DateTime(2026,10,2)),
       Trade(id:'sellbtc',coinId:'bitcoin',name:'Bitcoin',symbol:'btc',buy:false,quantity:2,price:90,fee:1,time:DateTime(2026,10,5))]));
     await save('06-portfolio');
     await tester.ensureVisible(find.text('Transaction history'));await settle();await save('07-transaction-history');
     c.tab.value=3;await save('08-research');
     await c.saveResearch(observation);await tap('Saved');await save('09-saved-research');
     await tap('Add research note');await save('10-research-note');await tap('Cancel');
     await route(CoinDetailPage(samples.first));await save('11-coin-detail');
     await tester.ensureVisible(find.text('Record trade'));await settle();
     unawaited(showTradeEditor(Get.context!,coin:samples.first));await save('12-record-trade');await back();await back();
     await route(const AlertsPage());await save('13-alerts-empty');
     await c.change((w)=>w.copy(alerts:[PriceAlert(id:'btc-above',coinId:'bitcoin',symbol:'btc',target:120,above:true),
       PriceAlert(id:'eth-alert',coinId:'ethereum',symbol:'eth',target:26,above:false,triggeredAt:DateTime(2026,10,13,8,0))]));
     await save('14-alerts');unawaited(showAlertEditor(Get.context!,samples.first));await save('15-create-alert');await tap('Cancel');await back();
     await route(const SettingsPage());await save('16-settings');
     await tester.ensureVisible(find.text('Export JSON'));await settle();await save('17-settings-data');
     await tap('Export JSON');await save('18-export-backup');await tap('Done');
     await tap('Restore JSON');await save('19-restore-backup');await tap('Cancel');
     await tester.ensureVisible(find.text('Display name'));await settle();await tap('Display name');await save('20-edit-profile');await tap('Cancel');
     account.available=true;await back();await route(const SettingsPage());await tap('Sign in or create account');await save('21-sign-in');
     await tap('Create an account');await save('22-create-account');await tap('Cancel');account.available=false;await back();
     c.tab.value=0;unawaited(showCoinSearch(Get.context!));await settle();await tester.enterText(find.byType(TextField).last,'bitcoin');
     await tester.pump(const Duration(milliseconds:500));await save('23-coin-search');await back();
     tester.view.physicalSize=const Size(1280,900);await save('24-desktop-markets');
     await c.change((w)=>w.copy(dark:false));tester.view.physicalSize=const Size(390,844);await save('25-light-theme');
   } finally {
     await tester.pumpWidget(const SizedBox.shrink());await Get.delete<WorkspaceController>(force:true);Get.reset();
     tester.view.resetPhysicalSize();tester.view.resetDevicePixelRatio();
   }
 });
}
