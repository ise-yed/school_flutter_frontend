import 'package:dio/dio.dart';

import '../../../core/constants/app_setting.dart';
import '../../../core/notifications/messaging_service.dart';
import '../../../core/utils/api_provider.dart';
import '../../../core/utils/app_error.dart';
import '../models/user_model.dart';

class ParentOtpVerifyResult {
  final bool requiresSchoolSelection;
  final List<SchoolOptionModel> schools;
  final UserModel? user;

  const ParentOtpVerifyResult({
    this.requiresSchoolSelection = false,
    this.schools = const [],
    this.user,
  });
}

class AuthServices {
  /// ورود کادر آموزشی، معلم و مدیر سیستم با نام کاربری و رمز عبور
  Future<UserModel> staffLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiProvider.post(
        'accounts/auth/staff/login/',
        data: {'username': username.trim(), 'password': password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final accessToken = data['access']?.toString();
        final userJson = data['user'];

        if (accessToken != null &&
            accessToken.isNotEmpty &&
            userJson is Map<String, dynamic>) {
          final user = UserModel.fromJson(userJson);
          await saveUserSession(accessToken: accessToken, user: user);
          if (user.id != null && user.id!.isNotEmpty && user.schoolId != null) {
            MessagingService.instance.onLogin(user.id!);
          }
          return user;
        }
      }

      throw AppException(
        AppErrorCode.unknown,
        serverMessage: 'پاسخ دریافتی از سرور معتبر نیست.',
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      throw AppException(AppErrorCode.unknown, serverMessage: e.message);
    }
  }

  /// درخواست کد یک‌بارمصرف (OTP) برای اولیا
  Future<String> requestParentOtp({
    required String phoneNumber,
    String? studentNationalCode,
  }) async {
    try {
      final Map<String, dynamic> payload = {'phone_number': phoneNumber.trim()};
      if (studentNationalCode != null &&
          studentNationalCode.trim().isNotEmpty) {
        payload['student_national_code'] = studentNationalCode.trim();
      }

      final response = await apiProvider.post(
        'accounts/auth/parent/otp/request/',
        data: payload,
      );

      final detail = response.data?['detail']?.toString();
      return (detail != null && detail.isNotEmpty)
          ? detail
          : 'کد تأیید ارسال شد.';
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      throw AppException(AppErrorCode.unknown, serverMessage: e.message);
    }
  }

  /// تأیید کد OTP اولیا (همراه با پشتیبانی از انتخاب مدرسه برای اولیای چندمدرسه‌ای)
  Future<ParentOtpVerifyResult> verifyParentOtp({
    required String phoneNumber,
    required String code,
    String? studentNationalCode,
    int? schoolId,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'phone_number': phoneNumber.trim(),
        'code': code.trim(),
      };
      if (studentNationalCode != null &&
          studentNationalCode.trim().isNotEmpty) {
        payload['student_national_code'] = studentNationalCode.trim();
      }
      if (schoolId != null) {
        payload['school_id'] = schoolId;
      }

      final response = await apiProvider.post(
        'accounts/auth/parent/otp/verify/',
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['requires_school_selection'] == true) {
          final rawSchools = data['schools'] as List? ?? [];
          final schools = rawSchools
              .whereType<Map>()
              .map(
                (e) => SchoolOptionModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
          return ParentOtpVerifyResult(
            requiresSchoolSelection: true,
            schools: schools,
          );
        }

        final accessToken = data['access']?.toString();
        final userJson = data['user'];
        if (accessToken != null &&
            accessToken.isNotEmpty &&
            userJson is Map<String, dynamic>) {
          final user = UserModel.fromJson(userJson);
          await saveUserSession(accessToken: accessToken, user: user);
          if (user.id != null && user.id!.isNotEmpty && user.schoolId != null) {
            MessagingService.instance.onLogin(user.id!);
          }
          return ParentOtpVerifyResult(user: user);
        }
      }

      throw AppException(
        AppErrorCode.unknown,
        serverMessage: 'پاسخ دریافتی از سرور معتبر نیست.',
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error as AppException;
      throw AppException(AppErrorCode.unknown, serverMessage: e.message);
    }
  }

  /// خروج از حساب کاربری و پاک‌سازی اطلاعات نشست
  Future<void> logout() async {
    final uid = currentUserModel.id;
    if (uid != null && uid.isNotEmpty) {
      MessagingService.instance.onLogout(uid);
    }
    await clearUserSession();
  }
}
