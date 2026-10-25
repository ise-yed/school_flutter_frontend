import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. Primary Palette (جایگزین‌شده با طیف Teal پزشکی از فایل design.md)
  // ===========================================================================
  static const Color primary50 = Color(
    0xFFE0F5F6,
  ); // Light Tint Surface (#E0F5F6)
  static const Color primary100 = Color(0xFF8DF2FF); // primary-fixed (#8df2ff)
  static const Color primary200 = Color(
    0xFF67D6E4,
  ); // primary-fixed-dim / inverse-primary (#67d6e4)
  static const Color primary300 = Color(
    0xFF0E9AA7,
  ); // Primary Teal Brand (#0E9AA7)
  static const Color primary400 = Color(
    0xFF00818C,
  ); // primary-container (#00818c)
  static const Color primary500 = Color(0xFF00666F); // primary (#00666f)
  static const Color primary600 = Color(
    0xFF086B75,
  ); // Dark Shade (#086B75) / surface-tint (#006972)
  static const Color primary700 = Color(
    0xFF004F56,
  ); // on-primary-fixed-variant (#004f56)
  static const Color primary800 = Color(
    0xFF001F23,
  ); // on-primary-fixed (#001f23)
  static const Color primary900 = Color(0xFF001417); // Deepest Teal

  // ===========================================================================
  // 2. Text & Surface Neutrals - Light Mode (بر اساس Neutrals & Surfaces)
  // ===========================================================================
  static const Color text50Light = Color(
    0xFFEEF2F5,
  ); // Muted Slate Fill (#EEF2F5) / surface-container-low (#eff4ff)
  static const Color text100Light = Color(
    0xFFE5EEFF,
  ); // surface-container (#e5eeff)
  static const Color text200Light = Color(
    0xFFE2E8F0,
  ); // Border / Divider (#E2E8F0)
  static const Color text300Light = Color(
    0xFFBCC9CB,
  ); // outline-variant (#bcc9cb)
  static const Color text400Light = Color(0xFF6D797B); // outline (#6d797b)
  static const Color text500Light = Color(
    0xFF64748B,
  ); // Text Secondary (#64748B)
  static const Color text600Light = Color(
    0xFF3D494A,
  ); // on-surface-variant (#3d494a)
  static const Color text700Light = Color(
    0xFF0F1C2C,
  ); // on-surface (#0f1c2c) / Text Primary (#1D2A3A)

  // ===========================================================================
  // 3. Text & Surface Neutrals - Dark Mode (بر اساس Inverse Tokens)
  // ===========================================================================
  static const Color text50Dark = Color(0xFF162230);
  static const Color text100Dark = Color(0xFF1D2A3A); // Text Primary Dark
  static const Color text200Dark = Color(
    0xFF243142,
  ); // inverse-surface (#243142)
  static const Color text300Dark = Color(0xFF64748B); // Slate Gray (#64748B)
  static const Color text400Dark = Color(0xFF6D797B); // outline (#6d797b)
  static const Color text500Dark = Color(
    0xFFBCC9CB,
  ); // outline-variant (#bcc9cb)
  static const Color text600Dark = Color(
    0xFFD6E3F9,
  ); // surface-variant (#d6e3f9)
  static const Color text700Dark = Color(
    0xFFFFFFFF,
  ); // on-primary / pure white (#ffffff)

  // ===========================================================================
  // 4. Backgrounds (Light & Dark)
  // ===========================================================================
  static const Color bg1Light = Color(0xFFF7FAFA); // Base Surface (#F7FAFA)
  static const Color bg2Light = Color(
    0xFFF8F9FF,
  ); // surface / background (#f8f9ff)

  static const Color bg1Dark = Color(
    0xFF0F1C2C,
  ); // on-surface as Dark Canvas (#0f1c2c)
  static const Color bg2Dark = Color(
    0xFF1D2A3A,
  ); // Deep Slate Charcoal (#1D2A3A)

  // ===========================================================================
  // 5. Status & Semantic Colors (جایگزین‌شده با Status System در design.md)
  // ===========================================================================
  // Confirmed (تأیید شده - Emerald Green)
  static const Color green = Color(0xFF059669);
  static const Color green2 = Color(0xFF059669);
  static const Color greenUpdate = Color(0xFF059669);
  static const Color subtextGreen = Color(0xFF059669);

  // Cancelled / Error / Alert (لغو شده و خطاها)
  static const Color subtextRed = Color(0xFFE11D48); // Rose Red (#E11D48)
  static const Color red = Color(0xFFBA1A1A); // error (#ba1a1a)
  static const Color lightRed = Color(0xFFFE6B64); // Accent Coral (#FE6B64)

  // Awaiting Approval / Secondary Ocean Blue (در انتظار تأیید پزشک و آبی‌ها)
  static const Color subtextBlue = Color(0xFF2563EB); // Cobalt Blue (#2563EB)
  static const Color blueLight = Color(0xFFD0E4FF); // secondary-fixed (#d0e4ff)
  static const Color blueDark = Color(
    0xFF001D35,
  ); // on-secondary-fixed (#001d35)

  // Awaiting Payment (در انتظار پرداخت - Amber)
  static const Color yellow = Color(0xFFD97706); // Amber (#D97706)
  static const Color yellowBack = Color(0xFFFEF3C7); // Amber 10% tint (#FEF3C7)
  static const Color yellowText = Color(0xFFD97706); // Amber (#D97706)

  // Misc & Dividers
  static const Color white100 = Color(0xFFE2E8F0); // Border / Divider (#E2E8F0)
  static const Color white50 = Color(0xFFFFDAD6); // error-container (#ffdad6)
  static const Color black100 = Color(0xFF1D2A3A); // Text Primary (#1D2A3A)
  static const Color black2050 = Color(0xFF243142); // inverse-surface (#243142)
  static const Color progressIndicatorDark = Color(0xFF3D494A);
  static const Color progressIndicatorLight = Color(0xFFD6E3F9);
  static const Color aroundYouHomeBannerColor = Color(
    0xFF00666F,
  ); // primary (#00666f)

  // ===========================================================================
  // 6. توکن‌های اختصاصی Material 3 و وضعیت‌ها از فایل design.md (برای صفحات جدید)
  // ===========================================================================
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCDDBF0);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD6E3F9);
  static const Color surfaceVariant = Color(0xFFD6E3F9);
  static const Color surfaceTint = Color(0xFF006972);

  static const Color onSurface = Color(0xFF0F1C2C);
  static const Color onSurfaceVariant = Color(0xFF3D494A);
  static const Color outline = Color(0xFF6D797B);
  static const Color outlineVariant = Color(0xFFBCC9CB);

  static const Color secondary = Color(0xFF1E629A); // secondary (#1e629a)
  static const Color secondaryOcean = Color(
    0xFF20639B,
  ); // Secondary Ocean Blue (#20639B)
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(
    0xFF87C0FE,
  ); // secondary-container (#87c0fe)
  static const Color onSecondaryContainer = Color(0xFF004E82);
  static const Color secondaryFixed = Color(0xFFD0E4FF);
  static const Color secondaryFixedDim = Color(0xFF9CCAFF);
  static const Color onSecondaryFixed = Color(0xFF001D35);
  static const Color onSecondaryFixedVariant = Color(0xFF00497B);

  static const Color tertiary = Color(0xFFAA2E2D); // tertiary (#aa2e2d)
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(
    0xFFCC4642,
  ); // tertiary-container (#cc4642)
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);
  static const Color tertiaryFixed = Color(0xFFFFDAD7);
  static const Color tertiaryFixedDim = Color(0xFFFFB3AD);
  static const Color onTertiaryFixed = Color(0xFF410004);
  static const Color onTertiaryFixedVariant = Color(0xFF8C171A);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Status Pairs (Foreground & 10% Background Tint)
  static const Color statusPendingPaymentFg = Color(0xFFD97706);
  static const Color statusPendingPaymentBg = Color(0xFFFEF3C7);

  static const Color statusPendingApprovalFg = Color(0xFF2563EB);
  static const Color statusPendingApprovalBg = Color(0xFFDBEAFE);

  static const Color statusConfirmedFg = Color(0xFF059669);
  static const Color statusConfirmedBg = Color(0xFFD1FAE5);

  static const Color statusCompletedFg = Color(0xFF64748B);
  static const Color statusCompletedBg = Color(0xFFF1F5F9);

  static const Color statusCancelledFg = Color(0xFFE11D48);
  static const Color statusCancelledBg = Color(0xFFFFE4E6);

  // Consultation Type Identifiers
  static const Color inPersonVisitFg = Color(0xFF086B75);
  static const Color inPersonVisitBg = Color(0xFFE0F5F6);
  static const Color onlineChatFg = Color(0xFF4F46E5);
  static const Color onlineChatBg = Color(0xFFEEF2FF);
}
