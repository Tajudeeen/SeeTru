// ── Error handler ──────────────────────────────────────────────────
  import 'package:dio/dio.dart';

String handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Check your internet.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 429) {
          return 'Rate limit reached. Try again in a minute.';
        }
        return 'Server error ($status). Try again.';
      default:
        return 'Something went wrong. Try again.';
    }
  }