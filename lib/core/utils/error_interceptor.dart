import 'dart:io';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/app_setting.dart';
import 'app_error.dart';
import 'network_connection.dart';

const _publicAuthPaths = [
  'accounts/auth/staff/login/',
  'accounts/auth/parent/otp/request/',
  'accounts/auth/parent/otp/verify/',
];

bool isPublicAuthPath(String path) =>
    _publicAuthPaths.any((p) => path.contains(p));

class ConnectivityAndErrorInterceptor extends Interceptor {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final status = await _connectivity.checkConnectivity();
    if (status == ConnectivityResult.none) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: AppException(AppErrorCode.noInternet),
          type: DioExceptionType.unknown,
        ),
      );
    }
    final online = await NetworkManager.hasInternetConnection();
    if (!online) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: AppException(AppErrorCode.noInternet),
          type: DioExceptionType.unknown,
        ),
      );
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final sc = response.statusCode ?? 0;
    if (sc >= 200 && sc < 300) {
      return handler.next(response);
    }

    // اگر توکن کاربر در یک مسیر محافظت‌شده منقضی شده باشد (401)، نشست را پاک می‌کنیم
    if (sc == 401 && !isPublicAuthPath(response.requestOptions.path)) {
      clearUserSession();
    }

    final data = response.data;
    final serverMessage = _extractMessage(data, headers: response.headers);

    String? serverErrorCode;
    Map<String, dynamic>? errors;
    if (data is Map) {
      if (data['error_code'] is String) serverErrorCode = data['error_code'];
      if (data['errors'] is Map) {
        errors = Map<String, dynamic>.from(data['errors']);
      }
    }

    return handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: AppException(
          _mapStatus(sc),
          serverMessage: serverMessage,
          serverErrorCode: serverErrorCode,
          errors: errors,
        ),
        type: DioExceptionType.badResponse,
      ),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppException) {
      return handler.next(err);
    }

    if (err.type == DioExceptionType.cancel) {
      return handler.next(
        err.copyWith(error: AppException(AppErrorCode.cancelled)),
      );
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return handler.next(
        err.copyWith(error: AppException(AppErrorCode.timeout)),
      );
    }

    if (err.type == DioExceptionType.badCertificate) {
      return handler.next(
        err.copyWith(error: AppException(AppErrorCode.sslError)),
      );
    }

    if (err.type == DioExceptionType.connectionError) {
      final underlying = err.error;
      if (underlying is SocketException) {
        final msg = underlying.message.toLowerCase();
        if (msg.contains('lookup') || msg.contains('failed host')) {
          return handler.next(
            err.copyWith(error: AppException(AppErrorCode.dnsError)),
          );
        }
        return handler.next(
          err.copyWith(error: AppException(AppErrorCode.noInternet)),
        );
      }
      if (underlying is HandshakeException) {
        return handler.next(
          err.copyWith(error: AppException(AppErrorCode.sslError)),
        );
      }
      if (underlying is HttpException) {
        return handler.next(
          err.copyWith(error: AppException(AppErrorCode.serverError)),
        );
      }
      return handler.next(
        err.copyWith(error: AppException(AppErrorCode.unknown)),
      );
    }

    if (err.type == DioExceptionType.badResponse) {
      final code = err.response?.statusCode ?? 0;
      if (code == 401 && !isPublicAuthPath(err.requestOptions.path)) {
        clearUserSession();
      }
      final mapped = _mapStatus(code);
      final data = err.response?.data;
      final serverMessage = _extractMessage(
        data,
        headers: err.response?.headers,
      );

      String? serverErrorCode;
      Map<String, dynamic>? errors;
      if (data is Map) {
        if (data['error_code'] is String) serverErrorCode = data['error_code'];
        if (data['errors'] is Map) {
          errors = Map<String, dynamic>.from(data['errors']);
        }
      }

      return handler.next(
        err.copyWith(
          error: AppException(
            mapped,
            serverMessage: serverMessage,
            serverErrorCode: serverErrorCode,
            errors: errors,
          ),
        ),
      );
    }

    return handler.next(
      err.copyWith(error: AppException(AppErrorCode.unknown)),
    );
  }

  String? _extractMessage(dynamic data, {Headers? headers, int maxLen = 256}) {
    String? contentType = headers?.value('content-type')?.toLowerCase();
    bool looksLikeHtml(String s) {
      final ss = s.trimLeft();
      return ss.startsWith('<!doctype html') ||
          ss.startsWith('<html') ||
          ss.contains('<head') ||
          ss.contains('<body');
    }

    String? msg;
    try {
      if (data is Map) {
        if (data['title'] is String && data['detail'] is String) {
          msg = '${data['title']}: ${data['detail']}';
        }
        msg ??= (data['message'] is String) ? data['message'] : null;
        msg ??= (data['detail'] is String) ? data['detail'] : null;
        msg ??= (data['error'] is String) ? data['error'] : null;

        if (msg == null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final parts = <String>[];
          errors.forEach((k, v) {
            if (v is List && v.isNotEmpty) {
              parts.add(v.first.toString());
            } else if (v is String && v.trim().isNotEmpty) {
              parts.add(v);
            }
          });
          if (parts.isNotEmpty) msg = parts.join('\n');
        }
      } else if (data is List && data.isNotEmpty) {
        msg = data.first.toString();
      } else if (data is String) {
        final s = data.trim();
        final isHtmlCt =
            (contentType != null && contentType.contains('text/html'));
        if (!isHtmlCt && !looksLikeHtml(s)) msg = s;
      }
    } catch (_) {
      msg = null;
    }
    if (msg != null && msg.length > maxLen) {
      msg = '${msg.substring(0, maxLen).trimRight()}…';
    }
    return msg;
  }

  AppErrorCode _mapStatus(int code) {
    switch (code) {
      case 400:
      case 422:
        return AppErrorCode.badRequest;
      case 401:
        return AppErrorCode.unauthorized;
      case 403:
        return AppErrorCode.forbidden;
      case 404:
        return AppErrorCode.notFound;
      case 409:
        return AppErrorCode.conflict;
      case 429:
        return AppErrorCode.tooManyRequests;
      case 502:
      case 504:
        return AppErrorCode.gatewayError;
      case 503:
        return AppErrorCode.maintenance;
      default:
        if (code >= 500) return AppErrorCode.serverError;
        return AppErrorCode.unknown;
    }
  }
}
