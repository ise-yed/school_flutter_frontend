import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/notifications/firebase_web_options.dart';

import 'core/constants/app_setting.dart';
import 'core/localization/locale_initializer.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/service/auth_service.dart';

import 'features/profile/bloc/profile_bloc.dart';
import 'features/profile/service/profile_service.dart';

import 'app.dart';
import 'core/notifications/messaging_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await initGlobalSettings();
  final Locale initialLocale = await determineInitialLocale();
  bool isFirebaseInitialized = false;
  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(options: firebaseWebOptions);
      } else {
        await Firebase.initializeApp();
      }
    }
    isFirebaseInitialized = Firebase.apps.isNotEmpty;
  } catch (e, stackTrace) {
    // چاپ کردن دلیل اصلی خطای فایربیس در کنسول
    debugPrint('🔥 Firebase initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fa'), Locale('en')],
      path: 'assets/translations',
      startLocale: initialLocale,
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => AuthBloc(AuthServices())),

          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(ProfileService()),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          enableScaleText: () => !kIsWeb,
          enableScaleWH: () => !kIsWeb,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) {
            return DevicePreview(
              enabled: false, // enabled: !kReleaseMode
              builder: (context) => const MyApp(),
            );
          },
        ),
      ),
    ),
  );

  if (isFirebaseInitialized) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessagingService.instance.initialize();
    });
  } else {
    debugPrint('⚠️ فایربیس راه‌اندازی نشد؛ سرویس نوتیفیکیشن غیرفعال ماند.');
  }
}
