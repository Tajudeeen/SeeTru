import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seetru/data/market_repository.dart';
import 'package:seetru/domain/models.dart';
import 'helpers.dart';

class Adapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) handler;
  Adapter(this.handler);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) => handler(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody body(dynamic value) => ResponseBody.fromString(
  jsonEncode(value),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);
void main() {
  test(
    'concurrent identical requests deduplicate without swallowing completion',
    () async {
      var calls = 0;
      final store = MemoryStore(), dio = Dio();
      dio.httpClientAdapter = Adapter((o) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return body([]);
      });
      final repo = MarketRepository(store, dio: dio);
      await Future.wait([
        repo.markets(ids: ['bitcoin']),
        repo.markets(ids: ['bitcoin']),
      ]);
      expect(calls, 1);
      await repo.markets(ids: ['ethereum']);
      expect(calls, 2);
      repo.close();
    },
  );
  test('network failure preserves cache timestamp', () async {
    final store = MemoryStore(), dio = Dio(), time = DateTime.utc(2020);
    await store.write('market_top', {
      'time': time.toIso8601String(),
      'coins': [
        const Coin(
          id: 'bitcoin',
          name: 'Bitcoin',
          symbol: 'btc',
          price: 100,
        ).toJson(),
      ],
    });
    dio.httpClientAdapter = Adapter(
      (o) async => throw DioException(requestOptions: o),
    );
    final repo = MarketRepository(store, dio: dio),
        r = await repo.markets(force: true);
    expect(r.cached, true);
    expect(r.fetchedAt, time);
    expect(r.warning, isNotNull);
    repo.close();
  });
  test('cache write failure preserves live data', () async {
    final store = MemoryStore()..fail = true;
    final dio = Dio()
      ..httpClientAdapter = Adapter(
        (o) async => body([
          {
            'id': 'bitcoin',
            'name': 'Bitcoin',
            'symbol': 'btc',
            'current_price': 123,
          },
        ]),
      );
    final repo = MarketRepository(store, dio: dio), r = await repo.markets();
    expect(r.coins.single.price, 123);
    expect(r.cached, false);
    expect(r.warning, isNotNull);
    repo.close();
  });
  test('corrupt cache does not block live request', () async {
    final store = MemoryStore();
    store.data['market_top'] = {'wrong': true};
    final dio = Dio()..httpClientAdapter = Adapter((o) async => body([]));
    final repo = MarketRepository(store, dio: dio);
    expect((await repo.markets()).cached, false);
    repo.close();
  });
}
