import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RateLimiter {
  final Map<String, List<DateTime>> _requestLog = {};
  final int maxRequests;
  final Duration window;

  RateLimiter({
    this.maxRequests = 30,
    this.window = const Duration(minutes: 1),
  });

  bool isAllowed(String key) {
    final now = DateTime.now();
    _requestLog[key] ??= [];
    _requestLog[key]!.removeWhere((t) => now.difference(t) > window);
    if (_requestLog[key]!.length >= maxRequests) return false;
    _requestLog[key]!.add(now);
    return true;
  }

  void reset(String key) => _requestLog.remove(key);
}

class InputSanitizer {
  static String sanitizeQuery(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"\\/]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .substring(0, input.length.clamp(0, 100));
  }

  static String sanitizeDisplay(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>]'), '')
        .substring(0, input.length.clamp(0, 500));
  }

  static bool isValidWalletAddress(String address) {
    final eth = RegExp(r'^0x[a-fA-F0-9]{40}$');
    final btc = RegExp(r'^(1|3|bc1)[a-zA-Z0-9]{25,62}$');
    return eth.hasMatch(address) || btc.hasMatch(address);
  }

  static bool isValidEmail(String email) => GetUtils.isEmail(email);

  static bool isSafe(String input) {
    return !RegExp(
      r'''(union|select|insert|update|delete|drop|--|;|'|")''',
      caseSensitive: false,
    ).hasMatch(input);
  }
}

void debugPrintSafe(String message) {
  if (kDebugMode) debugPrint('[SeeTru] $message');
}