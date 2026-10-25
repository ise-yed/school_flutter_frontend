import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/app_constants.dart';
import '../constants/app_setting.dart';
import 'error_interceptor.dart';

final Dio apiProvider =
    Dio(
        BaseOptions(
          baseUrl: AppConstants.appBaseUrl,
          validateStatus: (_) => true,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      )
      ..interceptors.addAll([
        ConnectivityAndErrorInterceptor(),
        LoggingInterceptor(),
      ]);

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isPublicAuthPath(options.path)) {
      final currentToken = prefs.getString(AppConstants.userToken) ?? '';
      if (currentToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $currentToken';
      }
    }

    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      final langCode = EasyLocalization.of(ctx)?.locale.languageCode ?? 'fa';
      options.headers['Accept-Language'] = langCode;
    } else {
      options.headers['Accept-Language'] = 'fa';
    }

    super.onRequest(options, handler);
  }
}
