import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/core/themes/app_colors.dart';
import 'package:school_flutter_frontend/core/utils/navigator.dart';
import 'package:school_flutter_frontend/core/utils/snakbar.dart';
import 'package:school_flutter_frontend/core/widgets/main_button.dart';
import 'package:school_flutter_frontend/core/widgets/main_textfield.dart';
import 'package:school_flutter_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:school_flutter_frontend/features/auth/screens/verify_code.dart';
import 'package:school_flutter_frontend/features/root/root_screen.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0 = ورود اولیا (OTP) | 1 = ورود کادر و معلمان (Username + Password)
  int _selectedTabIndex = 0;

  final GlobalKey<FormState> _parentFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _staffFormKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalCodeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showNationalCodeField = false;
  final Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _phoneController.dispose();
    _nationalCodeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _applyFieldErrors(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return;
    setState(() {
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          _fieldErrors[key] = value.first.toString();
        } else if (value != null) {
          _fieldErrors[key] = value.toString();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEn = context.locale.languageCode == 'en';

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is StaffLoginSuccess) {
              goScreen(
                context: context,
                screen: const RootScreen(),
                closeAllScreen: true,
              );
            } else if (state is StaffLoginError) {
              _applyFieldErrors(state.fieldErrors);
              if (state.message.isNotEmpty) {
                showCustomSnackBar(
                  context: context,
                  title: 'error_title'.tr(),
                  content: state.message,
                  status: ToastificationType.error,
                );
              }
            } else if (state is ParentOtpRequestSuccess) {
              showCustomSnackBar(
                context: context,
                title: 'success'.tr(),
                content: state.message,
                status: ToastificationType.success,
              );
              goScreen(
                context: context,
                screen: VerifyCodeScreen(
                  phoneNumber: state.phoneNumber,
                  studentNationalCode: state.studentNationalCode,
                ),
              );
            } else if (state is ParentOtpRequestError) {
              _applyFieldErrors(state.fieldErrors);
              if (state.message.isNotEmpty) {
                showCustomSnackBar(
                  context: context,
                  title: 'error_title'.tr(),
                  content: state.message,
                  status: ToastificationType.error,
                );
              }
            }
          },
          builder: (context, state) {
            final isLoading =
                state is StaffLoginLoading || state is ParentOtpRequestLoading;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Center(
                    child: SvgPicture.asset(
                      !isThemeLight.value
                          ? "assets/logo/logo_dark.svg"
                          : "assets/logo/logo_light.svg",
                      height: 88.h,
                      width: 88.w,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: Text(
                      isEn
                          ? 'School Management System'
                          : 'سامانه یکپارچه مدیریت مدرسه',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      isEn
                          ? 'Select your role to sign in'
                          : 'لطفاً بخش مربوط به خود را برای ورود انتخاب کنید',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // سوییچ انتخاب نوع ورود (اولیا / کادر و معلمان)
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: theme.colorScheme.surfaceDim),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRoleTabButton(
                            context: context,
                            index: 0,
                            title: isEn ? 'Parents (OTP)' : 'ورود اولیا',
                            icon: Icons.family_restroom_rounded,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: _buildRoleTabButton(
                            context: context,
                            index: 1,
                            title: isEn ? 'Staff & Teachers' : 'کادر و معلمان',
                            icon: Icons.school_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),

                  if (_selectedTabIndex == 0)
                    _buildParentOtpForm(context, isLoading, isEn)
                  else
                    _buildStaffLoginForm(context, isLoading, isEn),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleTabButton({
    required BuildContext context,
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_selectedTabIndex != index) {
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedTabIndex = index;
            _fieldErrors.clear();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary500 : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.r,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentOtpForm(BuildContext context, bool isLoading, bool isEn) {
    final theme = Theme.of(context);

    return Form(
      key: _parentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Parent Mobile Number' : 'شماره موبایل ولی',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          CoreTextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            hint: '0912xxxxxxx',
            errorText: _fieldErrors['phone_number'],
            inputFormatters: [LengthLimitingTextInputFormatter(12)],
            onChanged: (_) {
              if (_fieldErrors.containsKey('phone_number')) {
                setState(() => _fieldErrors.remove('phone_number'));
              }
            },
            suffix: SvgPicture.asset(
              "assets/icons/call.svg",
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.tertiary,
                BlendMode.srcIn,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return tr('required.phone');
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),

          // گزینه باز کردن فیلد کد ملی دانش‌آموز برای اولین درخواست اتصال
          InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () {
              setState(() {
                _showNationalCodeField = !_showNationalCodeField;
                if (!_showNationalCodeField) {
                  _nationalCodeController.clear();
                  _fieldErrors.remove('student_national_code');
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
              child: Row(
                children: [
                  Icon(
                    _showNationalCodeField
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 20.r,
                    color: AppColors.primary500,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isEn
                          ? 'First time logging in? Enter student national code'
                          : 'اولین بار است وارد می‌شوید؟ (ثبت کد ملی دانش‌آموز)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_showNationalCodeField) ...[
            SizedBox(height: 10.h),
            Text(
              isEn ? 'Student National Code' : 'کد ملی دانش‌آموز',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            CoreTextField(
              controller: _nationalCodeController,
              keyboardType: TextInputType.number,
              hint: isEn
                  ? '10-digit national code'
                  : 'کد ملی ۱۰ رقمی دانش‌آموز',
              errorText: _fieldErrors['student_national_code'],
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              onChanged: (_) {
                if (_fieldErrors.containsKey('student_national_code')) {
                  setState(() => _fieldErrors.remove('student_national_code'));
                }
              },
              suffix: Icon(
                Icons.badge_outlined,
                color: theme.colorScheme.tertiary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              isEn
                  ? 'If your phone number is not yet registered by the school, entering the student national code will submit a link request for school approval.'
                  : 'اگر شماره شما هنوز توسط مدرسه ثبت نشده است، با وارد کردن کد ملی فرزندتان درخواست اتصال برای تأیید کادر آموزشی ارسال می‌شود.',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5.sp),
            ),
          ],

          SizedBox(height: 32.h),
          CustomElevatedButton(
            loading: isLoading,
            text: "get_verification_code".tr(),
            onTap: () {
              if (_parentFormKey.currentState!.validate()) {
                setState(() => _fieldErrors.clear());
                context.read<AuthBloc>().add(
                  ParentRequestOtpEvent(
                    phoneNumber: _phoneController.text,
                    studentNationalCode: _showNationalCodeField
                        ? _nationalCodeController.text
                        : null,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaffLoginForm(BuildContext context, bool isLoading, bool isEn) {
    final theme = Theme.of(context);

    return Form(
      key: _staffFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Username' : 'نام کاربری',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          CoreTextField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            hint: isEn ? 'Enter your username' : 'نام کاربری خود را وارد کنید',
            errorText: _fieldErrors['username'],
            onChanged: (_) {
              if (_fieldErrors.containsKey('username')) {
                setState(() => _fieldErrors.remove('username'));
              }
            },
            suffix: Icon(
              Icons.person_outline_rounded,
              color: theme.colorScheme.tertiary,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return tr('required.username');
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          Text(
            isEn ? 'Password' : 'رمز عبور',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          CoreTextField(
            controller: _passwordController,
            obscure: true,
            hint: "password_hint".tr(),
            errorText: _fieldErrors['password'],
            onChanged: (_) {
              if (_fieldErrors.containsKey('password')) {
                setState(() => _fieldErrors.remove('password'));
              }
            },
            suffix: SvgPicture.asset(
              "assets/icons/lock.svg",
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.tertiary,
                BlendMode.srcIn,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return tr('required.password');
              }
              return null;
            },
          ),
          SizedBox(height: 32.h),
          CustomElevatedButton(
            loading: isLoading,
            text: "login".tr(),
            onTap: () {
              if (_staffFormKey.currentState!.validate()) {
                setState(() => _fieldErrors.clear());
                context.read<AuthBloc>().add(
                  StaffLoginEvent(
                    username: _usernameController.text,
                    password: _passwordController.text,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
