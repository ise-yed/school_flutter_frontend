part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

/// -------------------- Staff Login --------------------
class StaffLoginLoading extends AuthState {}

class StaffLoginSuccess extends AuthState {
  final UserModel user;

  StaffLoginSuccess(this.user);
}

class StaffLoginError extends AuthState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  StaffLoginError(this.message, {this.fieldErrors});
}

/// -------------------- Parent OTP Request --------------------
class ParentOtpRequestLoading extends AuthState {}

class ParentOtpRequestSuccess extends AuthState {
  final String message;
  final String phoneNumber;
  final String? studentNationalCode;

  ParentOtpRequestSuccess({
    required this.message,
    required this.phoneNumber,
    this.studentNationalCode,
  });
}

class ParentOtpRequestError extends AuthState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  ParentOtpRequestError(this.message, {this.fieldErrors});
}

/// -------------------- Parent OTP Verify --------------------
class ParentOtpVerifyLoading extends AuthState {}

class ParentOtpVerifySchoolSelectionRequired extends AuthState {
  final List<SchoolOptionModel> schools;
  final String phoneNumber;
  final String code;
  final String? studentNationalCode;

  ParentOtpVerifySchoolSelectionRequired({
    required this.schools,
    required this.phoneNumber,
    required this.code,
    this.studentNationalCode,
  });
}

class ParentOtpVerifySuccess extends AuthState {
  final UserModel user;

  ParentOtpVerifySuccess(this.user);
}

class ParentOtpVerifyError extends AuthState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  ParentOtpVerifyError(this.message, {this.fieldErrors});
}

/// -------------------- Logout --------------------
class LogoutLoading extends AuthState {}

class LogoutSuccess extends AuthState {}

class LogoutError extends AuthState {
  final String message;

  LogoutError(this.message);
}
