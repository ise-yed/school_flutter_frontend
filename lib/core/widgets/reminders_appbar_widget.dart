import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RemindersAppbarWidget extends StatelessWidget {
  Widget? leadingIcon;
  Widget? trailingIcon;
  final String title;
  double? horizontalPadding;
  TextStyle? titleAppbar;
  RemindersAppbarWidget({
    super.key,
    this.titleAppbar,
    this.leadingIcon,
    this.trailingIcon,
    required this.title,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding!.w),
      child: SizedBox(
        height: 72.h,
        width: MediaQuery.of(context).size.width,
        child: Row(
          spacing: 8.w,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leadingIcon != null
                ? leadingIcon!
                : SizedBox(width: 24.w, height: 24.h),
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                title.tr(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style:
                    titleAppbar ??
                    Theme.of(
                      context,
                    ).textTheme.headlineMedium!.copyWith(fontSize: 17.5.sp),
              ),
            ),
            trailingIcon != null
                ? trailingIcon!
                : SizedBox(width: 24.w, height: 24.h),
          ],
        ),
      ),
    );
  }
}
