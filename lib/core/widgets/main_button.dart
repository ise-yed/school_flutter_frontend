import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final bool revers;
  final bool loading;
  Widget? icon;
  double? iconSpace;
  double? buttonHeight;
  Color? buttonColor;
  Color? borderColor;

  TextStyle? textStyle;

  CustomElevatedButton({
    super.key,
    required this.onTap,
    required this.text,
    this.revers = false,
    this.loading = false,
    this.icon,
    this.iconSpace,
    this.buttonHeight = 56,
    this.buttonColor,
    this.textStyle,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    buttonColor = buttonColor ?? Theme.of(context).colorScheme.primary;
    textStyle =
        textStyle ??
        Theme.of(context).textTheme.headlineMedium!
            .copyWith(color: AppColors.text700Dark);
    return SizedBox(
      height: buttonHeight!.h,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: borderColor != null
                ? BorderSide(width: 1, color: borderColor!)
                : BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: revers
              ? Theme.of(context).colorScheme.background
              : buttonColor,
        ),
        child: loading
            ? CircularProgressIndicator(
                color: AppColors.primary500,
                constraints: BoxConstraints(
                  minWidth: 22.w,
                  minHeight: 22.h,
                  maxWidth: 24.w,
                  maxHeight: 24.h,
                ),
                strokeWidth: 3,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon != null
                      ? Row(
                          children: [
                            icon!,
                            SizedBox(width: iconSpace),
                          ],
                        )
                      : SizedBox(),
                  Text(text, style: textStyle),
                ],
              ),
      ),
    );
  }
}
