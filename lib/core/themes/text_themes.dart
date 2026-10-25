import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';

class DarkAppTextStyles {
  // headline-md (20px, weight 700)
  static TextStyle bodyLarge = TextStyle(
    fontSize: 20.sp,
    color: AppColors.text700Dark,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  // body-sm (12px, weight 400)
  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    color: AppColors.text500Dark,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // body-md (14px, weight 400)
  static TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    color: AppColors.text500Dark,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // label-md (12px, weight 500/600)
  static TextStyle labelMedium = TextStyle(
    fontSize: 12.sp,
    color: AppColors.primary200,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // headline-sm (18px, weight 600)
  static TextStyle headlineMedium = TextStyle(
    fontSize: 18.sp,
    color: AppColors.text700Dark,
    fontWeight: FontWeight.w600,
    height: 1.55,
  );

  // label-lg (14px, weight 600)
  static TextStyle titleMedium = TextStyle(
    fontSize: 14.sp,
    color: AppColors.text700Dark,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // label-sm (11px, weight 600)
  static TextStyle titleSmall = TextStyle(
    fontSize: 11.sp,
    color: AppColors.text500Dark,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );
}

class LightAppTextStyles {
  // headline-sm (18px, weight 600)
  static TextStyle headlineMedium = TextStyle(
    fontSize: 18.sp,
    color: AppColors.text700Light,
    fontWeight: FontWeight.w600,
    height: 1.55,
  );

  // body-md (14px, weight 400)
  static TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    color: AppColors.text500Light,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // label-lg (14px, weight 600)
  static TextStyle titleMedium = TextStyle(
    fontSize: 14.sp,
    color: AppColors.text700Light,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // headline-md (20px, weight 700)
  static TextStyle bodyLarge = TextStyle(
    fontSize: 20.sp,
    color: AppColors.text700Light,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  // body-sm (12px, weight 400)
  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    color: AppColors.text500Light,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // label-md (12px, weight 600)
  static TextStyle labelMedium = TextStyle(
    fontSize: 12.sp,
    color: AppColors.primary500,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // label-sm (11px, weight 600)
  static TextStyle titleSmall = TextStyle(
    fontSize: 11.sp,
    color: AppColors.text500Light,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );
}
