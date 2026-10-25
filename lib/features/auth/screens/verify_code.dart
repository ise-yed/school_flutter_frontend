import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/core/utils/snakbar.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:school_flutter_frontend/features/auth/models/user_model.dart';
import 'package:school_flutter_frontend/features/auth/widgets/back_button.dart';
import 'package:school_flutter_frontend/features/auth/widgets/otp_pinput.dart';
import 'package:school_flutter_frontend/features/root/root_screen.dart';
import 'package:toastification/toastification.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.phoneNumber,
    this.studentNationalCode,
  });

  final String phoneNumber;
  final String? studentNationalCode;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  final ValueNotifier<int> _secsLeft = ValueNotifier<int>(120);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secsLeft.value = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final v = _secsLeft.value;
      if (v <= 1) {
        _secsLeft.value = 0;
        t.cancel();
      } else {
        _secsLeft.value = v - 1;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secsLeft.dispose();
    otpController.dispose();
    super.dispose();
  }

  String _fmt(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _submit({int? schoolId}) {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    context.read<AuthBloc>().add(
      ParentVerifyOtpEvent(
        phoneNumber: widget.phoneNumber,
        code: otpController.text.trim(),
        studentNationalCode: widget.studentNationalCode,
        schoolId: schoolId,
      ),
    );
  }

  void _resendCode() {
    if (_secsLeft.value > 0) return;
    context.read<AuthBloc>().add(
      ParentRequestOtpEvent(
        phoneNumber: widget.phoneNumber,
        studentNationalCode: widget.studentNationalCode,
      ),
    );
    _startCountdown();
  }

  Future<void> _showSchoolSelectionBottomSheet(
    List<SchoolOptionModel> schools,
  ) async {
    final isEn = context.locale.languageCode == 'en';
    final selectedSchool = await showModalBottomSheet<SchoolOptionModel>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Select School' : 'انتخاب مدرسه',
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  isEn
                      ? 'Your phone number is registered in multiple schools. Please choose one:'
                      : 'شماره همراه شما در بیش از یک مدرسه ثبت شده است. لطفاً مدرسه موردنظر را انتخاب کنید:',
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: 16.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 280.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: schools.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (ctx, index) {
                      final school = schools[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: () => Navigator.pop(sheetCtx, school),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceBright,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: theme.colorScheme.surfaceDim,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38.r,
                                height: 38.r,
                                decoration: BoxDecoration(
                                  color: AppColors.primary500.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: AppColors.primary500,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  school.name,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.primary500,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedSchool != null && mounted) {
      _submit(schoolId: selectedSchool.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.locale.languageCode == 'en';

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is ParentOtpVerifySuccess) {
              _timer?.cancel();
              goScreen(
                context: context,
                screen: const RootScreen(),
                closeAllScreen: true,
              );
            } else if (state is ParentOtpVerifySchoolSelectionRequired) {
              _showSchoolSelectionBottomSheet(state.schools);
            } else if (state is ParentOtpVerifyError) {
              showCustomSnackBar(
                context: context,
                title: 'error_title'.tr(),
                content: state.message,
                status: ToastificationType.error,
              );
            } else if (state is ParentOtpRequestSuccess) {
              showCustomSnackBar(
                context: context,
                title: 'success'.tr(),
                content: state.message,
                status: ToastificationType.success,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ParentOtpVerifyLoading;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  bottom: 28.h,
                  top: 26.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthBackButton(onPressed: () => Navigator.pop(context)),
                    SizedBox(height: 56.h),
                    Text(
                      "verify_code".tr(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 14.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${"enter_code_part1".tr()} ",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          TextSpan(
                            text: " ${"enter_code_part2".tr()}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 34.h),
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Form(
                        key: _formKey,
                        child: OtpPinPut(
                          controller: otpController,
                          onCompleted: (_) => _submit(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all(Size.zero),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.zero,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: SvgPicture.asset(
                                  "assets/icons/edit.svg",
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onSecondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "edit_number".tr(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _secsLeft,
                          builder: (_, secs, __) {
                            if (secs > 0) {
                              return Text(
                                _fmt(secs),
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            }
                            return TextButton(
                              onPressed: _resendCode,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isEn ? 'Resend Code' : 'ارسال مجدد کد',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    CustomElevatedButton(
                      loading: isLoading,
                      onTap: () => _submit(),
                      text: "submit_code".tr(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
