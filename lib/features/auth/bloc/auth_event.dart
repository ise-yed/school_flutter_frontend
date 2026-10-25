part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

/// ورود کادر آموزشی، معلمان و مدیر سیستم
class StaffLoginEvent extends AuthEvent {
  final String username;
  final String password;

  StaffLoginEvent({required this.username, required this.password});
}

/// درخواست ارسال کد OTP برای اولیا
class ParentRequestOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String? studentNationalCode;

  ParentRequestOtpEvent({required this.phoneNumber, this.studentNationalCode});
}

/// تأیید کد OTP اولیا (و انتخاب مدرسه در صورت نیاز)
class ParentVerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String code;
  final String? studentNationalCode;
  final int? schoolId;

  ParentVerifyOtpEvent({
    required this.phoneNumber,
    required this.code,
    this.studentNationalCode,
    this.schoolId,
  });
}

/// خروج از حساب کاربری
class LogoutEvent extends AuthEvent {}
