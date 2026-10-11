import 'dart:convert';

double? number(dynamic value) {
  final n = value is num ? value.toDouble() : null;
  return n != null && n.isFinite ? n : null;
}

class Coin {
  final String id, name, symbol, image;
  final double? price, change, marketCap, volume;
  final int? rank;
  final DateTime? updatedAt;
  final List<double> sparkline;
  const Coin({required this.id, required this.name, required this.symbol,
    this.image = '', this.price, this.change, this.marketCap, this.volume,
    this.rank, this.updatedAt, this.sparkline = const []});
  factory Coin.fromJson(Map<String, dynamic> j) => Coin(
    id: j['id'] as String, name: j['name'] as String, symbol: j['symbol'] as String,
    image: j['image'] as String? ?? '', price: number(j['current_price']),
    change: number(j['price_change_percentage_24h']), marketCap: number(j['market_cap']),
    volume: number(j['total_volume']), rank: number(j['market_cap_rank'])?.toInt(),
    updatedAt: DateTime.tryParse(j['last_updated']?.toString() ?? ''),
    sparkline: ((j['sparkline_in_7d']?['price'] ?? []) as List).map(number).whereType<double>().toList());
  Map<String, dynamic> toJson() => {'id':id,'name':name,'symbol':symbol,'image':image,
    'current_price':price,'price_change_percentage_24h':change,'market_cap':marketCap,
    'total_volume':volume,'market_cap_rank':rank,'last_updated':updatedAt?.toIso8601String(),
    'sparkline_in_7d':{'price':sparkline}};
  bool freshAt(DateTime now) => updatedAt != null &&
    now.difference(updatedAt!).inSeconds >= -60 && now.difference(updatedAt!).inMinutes < 10;
}
class PricePoint {
  final DateTime time; final double value;
  const PricePoint(this.time, this.value);
}
class MarketSnapshot {
  final List<Coin> coins; final DateTime fetchedAt; final bool cached; final String? warning;
  const MarketSnapshot(this.coins,this.fetchedAt,{this.cached=false,this.warning});
}
class Trade {
  final String id, coinId, name, symbol;
  final bool buy; final double quantity, price, fee; final DateTime time;
  Trade({required this.id,required this.coinId,required this.name,required this.symbol,
    required this.buy,required this.quantity,required this.price,required this.fee,required this.time}) {
    if (id.isEmpty || coinId.isEmpty || !quantity.isFinite || quantity <= 0 ||
      !price.isFinite || price <= 0 || !fee.isFinite || fee < 0 ||
      !(quantity * price + fee).isFinite || (!buy && fee > quantity * price)) {
      throw const FormatException('Enter a valid quantity, price and fee.');
    }
  }
  factory Trade.fromJson(Map<String,dynamic> j) => Trade(id:j['id'],coinId:j['coinId'],
    name:j['name'],symbol:j['symbol'],buy:j['buy'],quantity:(j['quantity'] as num).toDouble(),
    price:(j['price'] as num).toDouble(),fee:(j['fee'] as num).toDouble(),time:DateTime.parse(j['time']));
  Map<String,dynamic> toJson()=>{'id':id,'coinId':coinId,'name':name,'symbol':symbol,
    'buy':buy,'quantity':quantity,'price':price,'fee':fee,'time':time.toIso8601String()};
}
class Position {
  double quantity=0, cost=0, realized=0;
  double get averageCost => quantity > 0 ? cost/quantity : 0;
}
Map<String,Position> calculatePositions(List<Trade> trades) {
  final indexed = trades.asMap().entries.toList()..sort((a,b) {
    final order=a.value.time.compareTo(b.value.time); return order==0?a.key.compareTo(b.key):order;
  });
  final result=<String,Position>{}; final ids=<String>{};
  for(final entry in indexed) {
    final t=entry.value;
    if(!ids.add(t.id)) throw const FormatException('Duplicate transaction ID.');
    final p=result.putIfAbsent(t.coinId,Position.new);
    if(t.buy) { p.quantity+=t.quantity; p.cost+=t.quantity*t.price+t.fee; }
    else {
      if(t.quantity>p.quantity+1e-10) throw const FormatException('A sale exceeds the holdings available on that date.');
      final basis=p.averageCost*t.quantity;
      p.realized+=t.quantity*t.price-t.fee-basis; p.quantity-=t.quantity; p.cost-=basis;
      if(p.quantity.abs()<1e-10) {p.quantity=0;p.cost=0;}
    }
    if(!p.quantity.isFinite || !p.cost.isFinite || !p.realized.isFinite) {
      throw const FormatException('Transaction totals exceed supported values.');
    }
  }
  return result;
}
class PriceAlert {
  final String id,coinId,symbol; final double target; final bool above,read;
  final DateTime? triggeredAt;
  PriceAlert({required this.id,required this.coinId,required this.symbol,required this.target,
    required this.above,this.read=false,this.triggeredAt}) {
    if(id.isEmpty||coinId.isEmpty||!target.isFinite||target<=0) throw const FormatException('Invalid alert.');
  }
  bool matches(Coin c,DateTime now)=>triggeredAt==null&&c.id==coinId&&c.price!=null&&c.freshAt(now)&&
    (above?c.price!>=target:c.price!<=target);
  PriceAlert copy({DateTime? triggeredAt,bool? read})=>PriceAlert(id:id,coinId:coinId,symbol:symbol,
    target:target,above:above,read:read??this.read,triggeredAt:triggeredAt??this.triggeredAt);
  factory PriceAlert.fromJson(Map<String,dynamic> j)=>PriceAlert(id:j['id'],coinId:j['coinId'],symbol:j['symbol'],
    target:(j['target'] as num).toDouble(),above:j['above'],read:j['read']??false,
    triggeredAt:DateTime.tryParse(j['triggeredAt']??''));
  Map<String,dynamic> toJson()=>{'id':id,'coinId':coinId,'symbol':symbol,'target':target,
    'above':above,'read':read,'triggeredAt':triggeredAt?.toIso8601String()};
}
class ResearchItem {
  final String id,category,title,body,source,url; final DateTime? publishedAt;
  const ResearchItem({required this.id,required this.category,required this.title,required this.body,
    required this.source,required this.url,this.publishedAt});
  factory ResearchItem.fromJson(Map<String,dynamic> j)=>ResearchItem(id:j['id'],category:j['category'],
    title:j['title'],body:j['body'],source:j['source'],url:j['url'],publishedAt:DateTime.tryParse(j['publishedAt']??''));
  Map<String,dynamic> toJson()=>{'id':id,'category':category,'title':title,'body':body,
    'source':source,'url':url,'publishedAt':publishedAt?.toIso8601String()};
}
class Workspace {
  final List<String> watchlist; final List<Trade> trades; final List<PriceAlert> alerts;
  final List<ResearchItem> saved; final String name; final bool dark,hideBalance,onboarded;
  const Workspace({this.watchlist=const [],this.trades=const [],this.alerts=const [],this.saved=const [],
    this.name='',this.dark=true,this.hideBalance=false,this.onboarded=false});
  Workspace copy({List<String>? watchlist,List<Trade>? trades,List<PriceAlert>? alerts,List<ResearchItem>? saved,
    String? name,bool? dark,bool? hideBalance,bool? onboarded})=>Workspace(watchlist:watchlist??this.watchlist,
    trades:trades??this.trades,alerts:alerts??this.alerts,saved:saved??this.saved,name:name??this.name,
    dark:dark??this.dark,hideBalance:hideBalance??this.hideBalance,onboarded:onboarded??this.onboarded);
  Map<String,dynamic> toJson()=>{'version':2,'watchlist':watchlist,'trades':trades.map((t)=>t.toJson()).toList(),
    'alerts':alerts.map((a)=>a.toJson()).toList(),'saved':saved.map((r)=>r.toJson()).toList(),
    'name':name,'dark':dark,'hideBalance':hideBalance,'onboarded':onboarded};
  String export()=>const JsonEncoder.withIndent('  ').convert(toJson());
  factory Workspace.fromJson(Map<String,dynamic> j) {
    if(j['version']!=2) throw const FormatException('Unsupported backup version.');
    final w=Workspace(watchlist:List<String>.from(j['watchlist']),
      trades:(j['trades'] as List).map((x)=>Trade.fromJson(Map<String,dynamic>.from(x))).toList(),
      alerts:(j['alerts'] as List).map((x)=>PriceAlert.fromJson(Map<String,dynamic>.from(x))).toList(),
      saved:(j['saved'] as List).map((x)=>ResearchItem.fromJson(Map<String,dynamic>.from(x))).toList(),
      name:j['name'],dark:j['dark'],hideBalance:j['hideBalance'],onboarded:j['onboarded']);
    if(w.watchlist.length>100||w.trades.length>10000||w.alerts.length>100||w.saved.length>1000||
      w.watchlist.toSet().length!=w.watchlist.length||w.name.length>80) {
      throw const FormatException('Backup exceeds workspace limits or contains duplicates.');
    }
    calculatePositions(w.trades); return w;
  }
  static Workspace parse(String text) {
    if(text.length>5000000) throw const FormatException('Backup is too large.');
    try {return Workspace.fromJson(jsonDecode(text));}
    catch(_) {throw const FormatException('Invalid or unsupported SeeTru backup.');}
  }
}
