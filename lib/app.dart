import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_flutter_frontend/features/home/home.dart';
import 'package:school_flutter_frontend/features/root/root_screen.dart';
import 'package:school_flutter_frontend/features/splash/screens/splash_screen.dart';

import 'core/constants/app_setting.dart';
import 'core/themes/app_theme.dart';

final ThemeData _lightTheme = AppTheme.lightTheme();
final ThemeData _darkTheme = AppTheme.darkTheme();

class MyScrollBehavior extends MaterialScrollBehavior {
  const MyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isThemeLight,
      builder: (context, isLight, child) {
        final currentLocale = context.locale.languageCode;

        final String fontFamily = currentLocale == 'en'
            ? 'Roboto'
            : 'IRANYekan';

        final List<String> fontFamilyFallback = currentLocale == 'en'
            ? ['IRANYekan']
            : ['Roboto'];

        return MaterialApp(
          title: 'school_flutter_frontend',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          navigatorObservers: [unfocusObserver],
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: _lightTheme.copyWith(
            textTheme: _lightTheme.textTheme.apply(
              fontFamily: fontFamily,
              fontFamilyFallback: fontFamilyFallback,
            ),
            primaryTextTheme: _lightTheme.primaryTextTheme.apply(
              fontFamily: fontFamily,
              fontFamilyFallback: fontFamilyFallback,
            ),
          ),
          darkTheme: _darkTheme.copyWith(
            textTheme: _darkTheme.textTheme.apply(
              fontFamily: fontFamily,
              fontFamilyFallback: fontFamilyFallback,
            ),
            primaryTextTheme: _darkTheme.primaryTextTheme.apply(
              fontFamily: fontFamily,
              fontFamilyFallback: fontFamilyFallback,
            ),
          ),
          themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
          themeAnimationDuration: Duration(milliseconds: 10),
          themeAnimationCurve: Curves.linear,
          scrollBehavior: const MyScrollBehavior(),
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final overlay = isDark
                ? const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.light,
                    systemNavigationBarDividerColor: Colors.transparent,
                  )
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.dark,
                    systemNavigationBarDividerColor: Colors.transparent,
                  );
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlay,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const maxW = 500.0;
                  const minH = 844.0;

                  final frameW = constraints.maxWidth > maxW
                      ? maxW
                      : constraints.maxWidth;

                  final isDesktopWeb = kIsWeb && constraints.maxWidth > maxW;
                  final isShort = isDesktopWeb && constraints.maxHeight < minH;
                  final frameH = isShort ? minH : constraints.maxHeight;

                  final mq = MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                    size: Size(frameW, frameH),
                  );

                  final content = MediaQuery(
                    data: mq,
                    child: SizedBox(
                      width: frameW,
                      height: frameH,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxW),
                      child: isShort
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: content,
                            )
                          : content,
                    ),
                  );
                },
              ),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
