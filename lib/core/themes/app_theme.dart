import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/themes/text_themes.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: 'IRANYekan',
      fontFamilyFallback: const ['Roboto'],

      brightness: Brightness.light,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.bg2Light,
      cardColor: AppColors.surfaceContainerLowest,
      indicatorColor: AppColors.progressIndicatorLight,
      canvasColor: AppColors.primary500,
      dividerColor: AppColors.text200Light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        onPrimary: AppColors.text700Dark,
        primaryContainer: AppColors.primary400,
        onPrimaryContainer: AppColors.primary50,
        secondary: AppColors.secondary,
        onSecondary: AppColors.text500Light,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.text400Light,
        onTertiary: AppColors.text300Light,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.bg2Light,
        onSurface: AppColors.text700Light,
        onSurfaceVariant: AppColors.text600Light,
        surfaceDim: AppColors.text200Light,
        surfaceTint: AppColors.surfaceTint,
        surfaceBright: AppColors.text50Light,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        tertiaryFixed: AppColors.text700Dark,
        onTertiaryFixed: AppColors.primary400,
        tertiaryFixedDim: AppColors.primary50,
        onPrimaryFixed: AppColors.primary100,
        onInverseSurface: AppColors.primary400,
        onSecondaryFixed: AppColors.white50,
        secondaryFixed: AppColors.blueLight,
        shadow: AppColors.surfaceContainerLowest,
        outline: AppColors.text200Light,
        outlineVariant: AppColors.text300Light,
        scrim: AppColors.text200Light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.text50Light, // #EEF2F5
        alignLabelWithHint: true,
        hintStyle: TextStyle(
          color: AppColors.text500Light, // #64748B
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(fontSize: 12.sp, color: AppColors.error),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.primary300, // #0E9AA7 (1.5px border on focus)
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.text200Light,
          ), // #E2E8F0
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.text200Light),
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          visualDensity: VisualDensity.compact,
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          backgroundColor: AppColors.primary500, // #00666F
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.text200Light, // #E2E8F0
          disabledForegroundColor: AppColors.text500Light, // #64748B
          elevation: 0.0,
          fixedSize: const Size(120.0, 48.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: LightAppTextStyles.bodyMedium,
        labelMedium: LightAppTextStyles.labelMedium,
        headlineMedium: LightAppTextStyles.headlineMedium,
        bodySmall: LightAppTextStyles.bodySmall,
        titleMedium: LightAppTextStyles.titleMedium,
        bodyLarge: LightAppTextStyles.bodyLarge,
        titleSmall: LightAppTextStyles.titleSmall,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: false,
      fontFamily: 'IRANYekan',
      fontFamilyFallback: const ['Roboto'],

      brightness: Brightness.dark,
      indicatorColor: AppColors.progressIndicatorDark,
      cardColor: AppColors.text200Dark,
      primaryColor: AppColors.primary500,
      canvasColor: AppColors.primary50,
      scaffoldBackgroundColor: AppColors.bg1Dark,
      dividerColor: AppColors.text200Dark,
      colorScheme: const ColorScheme.dark(
        onSecondaryFixed: AppColors.black2050,
        secondaryFixed: AppColors.blueDark,
        onPrimaryContainer: AppColors.bg2Dark,
        onInverseSurface: AppColors.primary50,
        tertiaryFixed: AppColors.black2050,
        onTertiaryFixed: AppColors.primary100,
        tertiaryFixedDim: AppColors.primary900,
        onPrimaryFixed: AppColors.primary700,
        primary: AppColors.primary300,
        onPrimary: Colors.white,
        surface: AppColors.bg2Dark,
        onSurface: AppColors.text700Dark,
        secondary: AppColors.text600Dark,
        onSecondary: AppColors.text500Dark,
        tertiary: AppColors.text400Dark,
        onTertiary: AppColors.text300Dark,
        error: AppColors.lightRed,
        surfaceDim: AppColors.text200Dark,
        surfaceTint: AppColors.text100Dark,
        surfaceBright: AppColors.text50Dark,
        shadow: AppColors.black100,
        outline: AppColors.text200Dark,
        scrim: AppColors.text200Dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.text50Dark,
        alignLabelWithHint: true,
        hintStyle: TextStyle(
          color: AppColors.text500Dark,
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: TextStyle(fontSize: 12.sp, color: AppColors.lightRed),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary200, width: 1.5),
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.text200Dark),
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.text200Dark),
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.lightRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.lightRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          visualDensity: VisualDensity.compact,
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0.0,
          fixedSize: const Size(120.0, 48.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      textTheme: TextTheme(
        titleSmall: DarkAppTextStyles.titleSmall,
        titleMedium: DarkAppTextStyles.titleMedium,
        bodySmall: DarkAppTextStyles.bodySmall,
        labelMedium: DarkAppTextStyles.labelMedium,
        headlineMedium: DarkAppTextStyles.headlineMedium,
        bodyMedium: DarkAppTextStyles.bodyMedium,
        bodyLarge: DarkAppTextStyles.bodyLarge,
      ),
    );
  }
}
