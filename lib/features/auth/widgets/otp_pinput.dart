import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_setting.dart';

class OtpPinPut extends StatelessWidget {
  OtpPinPut({
    super.key,
    // required this.code,
    required this.controller,
    required this.onCompleted,
  });

  // final String code;
  final TextEditingController controller;
  final void Function(String? pin) onCompleted;

  final defaultPinTheme = PinTheme(
    width: 76.5.w,
    height: 58.h,
    textStyle: Theme.of(navigatorKey.currentContext!).textTheme.bodyLarge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: Theme.of(navigatorKey.currentContext!).colorScheme.surfaceDim,
      ),
      color: Theme.of(navigatorKey.currentContext!).colorScheme.surfaceBright,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Pinput(
        controller: controller,
        defaultPinTheme: defaultPinTheme,
        length: 6,
        separatorBuilder: (index) => SizedBox(width: 12.w),
        validator: (value) {
          final v = value?.trim() ?? '';
          if (v.isEmpty) {
            return 'required.otp_code'.tr();
          }
          // else if (v != code) {
          //   return 'incorrect_otp_code'.tr();
          // }
          return null;
        },
        errorBuilder: (errorText, pin) => Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText ?? '',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Colors.red),
            ),
          ),
        ),
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        onCompleted: onCompleted,
        onChanged: (value) {},
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(
              color: Theme.of(navigatorKey.currentContext!).colorScheme.primary,
              width: 1.5.w,
            ),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.green),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyBorderWith(
          border: Border.all(color: Colors.red),
        ),
      ),
    );
  }
}
