import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_colors.dart';

class GlobalLoadingSection extends StatelessWidget {
  EdgeInsetsGeometry? padding;
  GlobalLoadingSection({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0.h),
      child: Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.symmetric(vertical: 56.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          // color: cs.surfaceBright,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary500),
            SizedBox(height: 16.h),
            Text(
              'loading'.tr(),
              style: TextStyle(fontSize: 15.sp, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
