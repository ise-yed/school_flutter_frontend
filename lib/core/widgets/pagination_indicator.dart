import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_colors.dart';

class GlobalPaginationLoadingSection extends StatelessWidget {
  const GlobalPaginationLoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          // color: cs.surfaceBright,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(color: AppColors.primary500),
            ),
            SizedBox(height: 10.h),
            Text(
              'loading'.tr(),
              style: TextStyle(fontSize: 12.sp, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
