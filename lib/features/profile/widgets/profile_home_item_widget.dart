import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileHomeItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final bool showRedDot;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileHomeItem({
    super.key,
    required this.iconPath,
    required this.title,
    this.showRedDot = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52.h,
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSecondary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (showRedDot) ...[
              Container(
                width: 11.w,
                height: 11.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            SizedBox(width: showRedDot ? 12.w : 8.w),
            trailing ??
                RotatedBox(
                  quarterTurns: isRTL ? 0 : 2,
                  child: SvgPicture.asset(
                    "assets/icons/direction-left 2.svg",
                    width: 24.w,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
