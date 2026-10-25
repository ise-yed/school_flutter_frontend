import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String title,
  required String content,
  required ToastificationType status,
}) {
    toastification.dismissAll();

  toastification.show(
    context: context,
    type: status,
    style: ToastificationStyle.fillColored,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    description: Text(
      content,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    alignment: Alignment.topRight,

    primaryColor: status == ToastificationType.error
        ? const Color(0xFFDB0012)
        : status == ToastificationType.success
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFFD600),


    autoCloseDuration: Duration(seconds: 6),
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: highModeShadow,
    dragToClose: true,
    pauseOnHover: false,
    applyBlurEffect: true,
    showProgressBar: true,
  );
}
