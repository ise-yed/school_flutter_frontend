import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/app_setting.dart';
import '../../../core/utils/navigator.dart';
import '../../../core/widgets/main_button.dart';
import '../../auth/models/user_model.dart';

import 'package:school_flutter_frontend/core/widgets/reminders_appbar_widget.dart';

import '../../auth/service/auth_service.dart';
import '../../splash/screens/splash_screen.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      height: 269.h,
      padding: EdgeInsets.only(bottom: 23.h, right: 24.w, left: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RemindersAppbarWidget(
            horizontalPadding: 0,
            title: "logout".tr(),
            trailingIcon: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: SvgPicture.asset(
                "assets/icons/remove.svg",
                width: 24.w,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: 26.h),
          Text(
            "log_out_des".tr(),
            style: Theme.of(context).textTheme.bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(height: 54.h),
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  textStyle: Theme.of(context).textTheme.headlineMedium!
                      .copyWith(fontSize: 12.75.sp),

                  onTap: () {
                    Navigator.pop(context);
                  },
                  text: "cancel".tr(),
                  buttonColor: Theme.of(context).colorScheme.surfaceTint,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomElevatedButton(
                  textStyle: Theme.of(context).textTheme.headlineMedium!
                      .copyWith(
                        fontSize: 12.75.sp,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                  buttonColor: Theme.of(context).colorScheme.tertiaryFixedDim,
                  onTap: () async {
                    try {
                      await AuthServices().logout();
                    } catch (_) {}
                    await prefs.clear();
                    isLogin.value = false;
                    currentUserModel = UserModel();
                    if (!context.mounted) return;
                    goScreen(
                      context: context,
                      screen: const SplashScreen(),
                      closeAllScreen: true,
                    );
                  },
                  text: "logout".tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
