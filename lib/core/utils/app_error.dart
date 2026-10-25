import 'package:easy_localization/easy_localization.dart';

enum AppErrorCode {
  noInternet,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  tooManyRequests,
  maintenance,
  serverError,
  gatewayError,
  sslError,
  dnsError,
  cancelled,
  unknown,
}

class AppException implements Exception {
  final AppErrorCode code;
  final String? serverMessage;
  final String? serverErrorCode;
  final Map<String, dynamic>? errors;

  AppException(
    this.code, {
    this.serverMessage,
    this.serverErrorCode,
    this.errors,
  });

  String get i18nKey {
    switch (code) {
      case AppErrorCode.noInternet:
        return 'error.no_internet';
      case AppErrorCode.timeout:
        return 'error.timeout';
      case AppErrorCode.badRequest:
        return 'error.bad_request';
      case AppErrorCode.unauthorized:
        return 'error.unauthorized';
      case AppErrorCode.forbidden:
        return 'error.forbidden';
      case AppErrorCode.notFound:
        return 'error.not_found';
      case AppErrorCode.conflict:
        return 'error.conflict';
      case AppErrorCode.tooManyRequests:
        return 'error.too_many_requests';
      case AppErrorCode.maintenance:
        return 'error.maintenance';
      case AppErrorCode.serverError:
        return 'error.server_error';
      case AppErrorCode.gatewayError:
        return 'error.gateway_error';
      case AppErrorCode.sslError:
        return 'error.ssl_error';
      case AppErrorCode.dnsError:
        return 'error.dns_error';
      case AppErrorCode.cancelled:
        return 'error.cancelled';
      case AppErrorCode.unknown:
        return 'error.unknown';
    }
  }

  String toDisplayMessage({bool includeFieldErrors = true}) =>
      getAppErrorMessage(this, includeFieldErrors: includeFieldErrors);

  @override
  String toString() => 'AppException($code, $serverMessage)';
}

bool _isGenericBackendMessage(String? msg) {
  if (msg == null) return true;
  final clean = msg.trim().toLowerCase();
  return clean.isEmpty ||
      clean == 'invalid input provided.' ||
      clean == 'invalid input provided' ||
      clean == 'اطلاعات ورودی نامعتبر است.' ||
      clean == 'اطلاعات ورودی نامعتبر است' ||
      clean == 'an error occurred.' ||
      clean == 'an error occurred' ||
      clean == 'خطایی رخ داده است.' ||
      clean == 'خطایی رخ داده است' ||
      clean == 'bad request.' ||
      clean == 'bad request' ||
      clean == 'درخواست نامعتبر است.' ||
      clean == 'درخواست نامعتبر است';
}

List<String> _extractErrorStrings(dynamic val) {
  final List<String> result = [];
  if (val is List) {
    for (final item in val) {
      if (item != null) {
        final s = item.toString().trim();
        if (s.isNotEmpty) result.add(s);
      }
    }
  } else if (val != null) {
    final s = val.toString().trim();
    if (s.isNotEmpty) result.add(s);
  }
  return result;
}

String getAppErrorMessage(Object e, {bool includeFieldErrors = true}) {
  if (e is AppException) {
    final String? serverMsg =
        (e.serverMessage != null && e.serverMessage!.trim().isNotEmpty)
        ? e.serverMessage!.trim()
        : null;

    final bool isGeneric = _isGenericBackendMessage(serverMsg);

    List<String> nonFieldErrors = [];
    if (e.errors != null && e.errors!.isNotEmpty) {
      if (e.errors!.containsKey('non_field_errors')) {
        nonFieldErrors = _extractErrorStrings(e.errors!['non_field_errors']);
      } else if (e.errors!.containsKey('detail')) {
        nonFieldErrors = _extractErrorStrings(e.errors!['detail']);
      }
    }

    if (!includeFieldErrors) {
      if (nonFieldErrors.isNotEmpty) {
        return nonFieldErrors.join('\n');
      }
      if (serverMsg != null && !isGeneric) {
        return serverMsg;
      }
      if (e.errors != null && e.errors!.isNotEmpty) {
        for (final entry in e.errors!.entries) {
          final errs = _extractErrorStrings(entry.value);
          if (errs.isNotEmpty) {
            return errs.join('\n');
          }
        }
      }
      if (serverMsg != null && serverMsg.isNotEmpty) {
        return serverMsg;
      }
      return e.i18nKey.tr();
    }

    final List<String> formattedErrors = [...nonFieldErrors];

    if (e.errors != null && e.errors!.isNotEmpty) {
      e.errors!.forEach((key, value) {
        if (key == 'non_field_errors' || key == 'detail') return;
        final list = _extractErrorStrings(value);
        for (final err in list) {
          formattedErrors.add(err);
        }
      });
    }

    String result = '';
    if (serverMsg != null && !isGeneric) {
      result = serverMsg;
    }

    if (formattedErrors.isNotEmpty) {
      final joined = formattedErrors.join('\n');
      result = result.isNotEmpty ? '$result\n$joined' : joined;
    }

    if (result.isNotEmpty) return result;
    if (serverMsg != null && serverMsg.isNotEmpty) return serverMsg;
    return e.i18nKey.tr();
  }

  return e.toString();
}
