import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/core/widgets/reminders_appbar_widget.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/widgets.dart' as ui;

import '../../../core/utils/snakbar.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({
    super.key,
    required this.hasUpdate,
    required this.showBack,
  });

  final bool hasUpdate;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final bool isRTL = Directionality.of(context) == ui.TextDirection.rtl;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            RemindersAppbarWidget(
              title: "update_title",
              leadingIcon: showBack
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: RotatedBox(
                        quarterTurns: isRTL ? 0 : 2,
                        child: SvgPicture.asset(
                          "assets/icons/arrow-right.svg",
                          width: 24.w,
                          height: 24.h,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(width: 24),
            ),
            if (hasUpdate) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 93.h),
                    SvgPicture.asset(
                      "assets/icons/reload.svg",
                      height: 82.h,
                      width: 82.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.yellowText,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      "${"current_version".tr()} (Build $appBuildVersion) $appVersion",
                      style: Theme.of(context).textTheme.titleSmall!
                          .copyWith(fontSize: 12.75.sp),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Text(
                        "new_version_available".tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        bottom: 31.h,
                      ),
                      child: CustomElevatedButton(
                        onTap: () async {
                          if (!await launchUrl(
                            Uri.parse(
                              'https://www.school_flutter_frontend.app/',
                            ),
                            mode: LaunchMode.externalApplication,
                          )) {
                            showCustomSnackBar(
                              context: context,
                              title: "error_title".tr(),
                              content: "error.link".tr(),
                              status: ToastificationType.error,
                            );
                          }
                        },
                        text: "update".tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 93.h),
                    SvgPicture.asset(
                      "assets/icons/check-circle.svg",
                      height: 82.h,
                      width: 82.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.greenUpdate,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      "${"current_version".tr()} (Build $appBuildVersion) $appVersion",
                      style: Theme.of(context).textTheme.titleSmall!
                          .copyWith(fontSize: 12.75.sp),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Text(
                        "your_app_is_uptodate".tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        bottom: 31.h,
                      ),
                      child: CustomElevatedButton(
                        borderColor: Theme.of(context).colorScheme.primary,
                        buttonColor: Theme.of(context).scaffoldBackgroundColor,
                        textStyle: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        text: "back".tr(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
