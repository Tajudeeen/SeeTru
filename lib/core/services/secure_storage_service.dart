import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
  static SecureStorageService get to => Get.find();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // AES-256 on Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── Keys ───────────────────────────────────────────────────────────
  static const String _coinGeckoKey    = 'api_coingecko';
  static const String _coinMarketCap   = 'api_cmc';
  static const String _cryptoRankKey   = 'api_cryptorank';
  static const String _duneKey         = 'api_dune';
  static const String _xBearerKey      = 'api_x_bearer';
  static const String _authTokenKey    = 'auth_token';
  static const String _refreshToken    = 'refresh_token';
  static const String _biometricKey    = 'biometric_enabled';
  static const String _pinHashKey      = 'pin_hash';
  static const String _sessionKey      = 'session_id';

  // ── API Keys ───────────────────────────────────────────────────────
  Future<void> saveCoinGeckoKey(String v)  async => _storage.write(key: _coinGeckoKey, value: v);
  Future<void> saveCMCKey(String v)        async => _storage.write(key: _coinMarketCap, value: v);
  Future<void> saveCryptoRankKey(String v) async => _storage.write(key: _cryptoRankKey, value: v);
  Future<void> saveDuneKey(String v)       async => _storage.write(key: _duneKey, value: v);
  Future<void> saveXBearerToken(String v)  async => _storage.write(key: _xBearerKey, value: v);

  Future<String?> getCoinGeckoKey()    async => _storage.read(key: _coinGeckoKey);
  Future<String?> getCMCKey()          async => _storage.read(key: _coinMarketCap);
  Future<String?> getCryptoRankKey()   async => _storage.read(key: _cryptoRankKey);
  Future<String?> getDuneKey()         async => _storage.read(key: _duneKey);
  Future<String?> getXBearerToken()    async => _storage.read(key: _xBearerKey);

  // ── Auth ───────────────────────────────────────────────────────────
  Future<void> saveAuthToken(String v)    async => _storage.write(key: _authTokenKey, value: v);
  Future<String?> getAuthToken()          async => _storage.read(key: _authTokenKey);
  Future<void> saveRefreshToken(String v) async => _storage.write(key: _refreshToken, value: v);
  Future<String?> getRefreshToken()       async => _storage.read(key: _refreshToken);

  // ── Biometric / PIN ────────────────────────────────────────────────
  Future<void> setBiometricEnabled(bool v) async =>
      _storage.write(key: _biometricKey, value: v.toString());
  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricKey);
    return val == 'true';
  }

  Future<void> savePinHash(String hash) async =>
      _storage.write(key: _pinHashKey, value: hash);
  Future<String?> getPinHash() async => _storage.read(key: _pinHashKey);

  // ── Session ────────────────────────────────────────────────────────
  Future<void> saveSessionId(String id) async =>
      _storage.write(key: _sessionKey, value: id);
  Future<String?> getSessionId() async => _storage.read(key: _sessionKey);

  // ── Clear ──────────────────────────────────────────────────────────
  Future<void> clearTokens() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _refreshToken);
    await _storage.delete(key: _sessionKey);
  }

  Future<void> clearAll() async => _storage.deleteAll();
}