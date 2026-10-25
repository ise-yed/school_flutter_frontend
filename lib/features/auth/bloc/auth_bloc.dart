import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/utils/app_error.dart';
import '../models/user_model.dart';
import '../service/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthServices authServices;

  AuthBloc(this.authServices) : super(AuthInitial()) {
    on<StaffLoginEvent>(_onStaffLogin);
    on<ParentRequestOtpEvent>(_onParentRequestOtp);
    on<ParentVerifyOtpEvent>(_onParentVerifyOtp);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onStaffLogin(
    StaffLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(StaffLoginLoading());
    try {
      final user = await authServices.staffLogin(
        username: event.username,
        password: event.password,
      );
      emit(StaffLoginSuccess(user));
    } catch (e) {
      Map<String, dynamic>? errors;
      if (e is AppException) {
        errors = e.errors;
      }
      emit(
        StaffLoginError(
          _errMsg(e, includeFieldErrors: false),
          fieldErrors: errors,
        ),
      );
    }
  }

  Future<void> _onParentRequestOtp(
    ParentRequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ParentOtpRequestLoading());
    try {
      final message = await authServices.requestParentOtp(
        phoneNumber: event.phoneNumber,
        studentNationalCode: event.studentNationalCode,
      );
      emit(
        ParentOtpRequestSuccess(
          message: message,
          phoneNumber: event.phoneNumber.trim(),
          studentNationalCode: event.studentNationalCode?.trim(),
        ),
      );
    } catch (e) {
      Map<String, dynamic>? errors;
      if (e is AppException) {
        errors = e.errors;
      }
      emit(
        ParentOtpRequestError(
          _errMsg(e, includeFieldErrors: false),
          fieldErrors: errors,
        ),
      );
    }
  }

  Future<void> _onParentVerifyOtp(
    ParentVerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ParentOtpVerifyLoading());
    try {
      final result = await authServices.verifyParentOtp(
        phoneNumber: event.phoneNumber,
        code: event.code,
        studentNationalCode: event.studentNationalCode,
        schoolId: event.schoolId,
      );

      if (result.requiresSchoolSelection) {
        emit(
          ParentOtpVerifySchoolSelectionRequired(
            schools: result.schools,
            phoneNumber: event.phoneNumber,
            code: event.code,
            studentNationalCode: event.studentNationalCode,
          ),
        );
      } else if (result.user != null) {
        emit(ParentOtpVerifySuccess(result.user!));
      } else {
        emit(ParentOtpVerifyError('خطا در دریافت اطلاعات کاربری'));
      }
    } catch (e) {
      Map<String, dynamic>? errors;
      if (e is AppException) {
        errors = e.errors;
      }
      emit(
        ParentOtpVerifyError(
          _errMsg(e, includeFieldErrors: false),
          fieldErrors: errors,
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(LogoutLoading());
    try {
      await authServices.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutError(_errMsg(e)));
    }
  }

  String _errMsg(Object e, {bool includeFieldErrors = true}) {
    return getAppErrorMessage(e, includeFieldErrors: includeFieldErrors);
  }
}
