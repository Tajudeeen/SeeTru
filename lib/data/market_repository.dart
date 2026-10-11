import 'package:dio/dio.dart';
import '../domain/models.dart';
import 'local_store.dart';
class DataFailure implements Exception {
  final String message;
  const DataFailure(this.message);
  @override String toString()=>message;
}
String friendlyError(Object e) {
  if(e is DataFailure) return e.message;
  if(e is FormatException) return e.message;
  if(e is DioException) {
    if(e.response?.statusCode==429) return 'The data provider is rate limiting requests. Try again shortly.';
    if([401,403].contains(e.response?.statusCode)) return 'The data provider rejected this request.';
    return 'Could not reach the data provider. Check your connection and try again.';
  }
  return 'The operation could not be completed. Please try again.';
}
class MarketRepository {
  final KeyValueStore store; final Dio dio; final String apiBase;
  final Map<String,Future<MarketSnapshot>> _pending={};
  MarketRepository(this.store,{Dio? dio,this.apiBase=''}) : dio=dio??Dio(BaseOptions(
    connectTimeout:const Duration(seconds:12),receiveTimeout:const Duration(seconds:20)));
  String get marketBase=>apiBase.isEmpty?'https://api.coingecko.com/api/v3':'${apiBase.replaceAll(RegExp(r'/$'),'')}/v1/market';
  Future<MarketSnapshot> markets({List<String> ids=const [],bool force=false}) {
    final sorted=ids.toSet().toList()..sort(); final key=sorted.isEmpty?'top':sorted.join(',');
    return _pending.putIfAbsent(key,()=>_markets(sorted,key,force).whenComplete(() {_pending.remove(key);}));
  }
  Future<MarketSnapshot> _markets(List<String> ids,String key,bool force) async {
    MarketSnapshot? previous;
    try {
      final raw=store.read('market_$key');
      if(raw!=null) previous=MarketSnapshot((raw['coins'] as List).map((j)=>Coin.fromJson(Map<String,dynamic>.from(j))).toList(),
        DateTime.parse(raw['time']),cached:true);
    } catch(_) { /* Invalid cache must not block a new request. */ }
    if(!force && previous!=null && DateTime.now().difference(previous.fetchedAt)<const Duration(minutes:2)) return previous;
    try {
      final response=await dio.get('$marketBase/coins/markets',queryParameters:{'vs_currency':'usd',
        'order':'market_cap_desc','per_page':100,'page':1,'sparkline':true,if(ids.isNotEmpty)'ids':ids.join(',')});
      final list=(response.data as List).map((j)=>Coin.fromJson(Map<String,dynamic>.from(j))).toList();
      final time=DateTime.now().toUtc(); String? warning;
      try {await store.write('market_$key',{'coins':list.map((c)=>c.toJson()).toList(),'time':time.toIso8601String()});}
      catch(_) {warning='Live data loaded, but the offline cache could not be saved.';}
      return MarketSnapshot(list,time,warning:warning);
    } catch(e) {
      if(previous!=null) return MarketSnapshot(previous.coins,previous.fetchedAt,cached:true,warning:friendlyError(e));
      rethrow;
    }
  }
  Future<List<Coin>> search(String query) async {
    final r=await dio.get('$marketBase/search',queryParameters:{'query':query});
    return (r.data['coins'] as List).take(20).map((j)=>Coin(id:j['id'],name:j['name'],symbol:j['symbol'],
      image:j['large']??j['thumb']??'',rank:number(j['market_cap_rank'])?.toInt())).toList();
  }
  Future<List<PricePoint>> chart(String id,int days) async {
    final r=await dio.get('$marketBase/coins/${Uri.encodeComponent(id)}/market_chart',queryParameters:{'vs_currency':'usd','days':days});
    return (r.data['prices'] as List).where((p)=>p is List&&p.length==2&&number(p[0])!=null&&number(p[1])!=null)
      .map((p)=>PricePoint(DateTime.fromMillisecondsSinceEpoch((p[0] as num).toInt(),isUtc:true),(p[1] as num).toDouble())).toList();
  }
  Future<Map<String,dynamic>> global() async=>Map<String,dynamic>.from((await dio.get('$marketBase/global')).data['data']);
  Future<Map<String,dynamic>> research() async {
    if(apiBase.isEmpty) return {'items':[],'providers':{'CryptoRank':'not_configured','Dune':'not_configured','X':'not_configured'}};
    return Map<String,dynamic>.from((await dio.get('${apiBase.replaceAll(RegExp(r'/$'),'')}/v1/research')).data);
  }
  void close()=>dio.close();
}
