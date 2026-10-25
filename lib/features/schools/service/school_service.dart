import 'package:dio/dio.dart';

import '../../../core/utils/api_provider.dart';
import '../../../core/utils/app_error.dart';
import '../models/school_models.dart';

class SchoolService {
  Never _rethrow(DioException e) {
    if (e.error is AppException) throw e.error as AppException;
    throw AppException(AppErrorCode.unknown, serverMessage: e.message);
  }

  // ==================== ۱. مدیریت مدارس (SUPERUSER) ====================
  Future<PaginatedResponse<SchoolModel>> getSchools({int page = 1}) async {
    try {
      final res = await apiProvider.get(
        'schools/manage/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, SchoolModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<SchoolModel> createSchool({
    required String name,
    required String code,
    bool isActive = true,
  }) async {
    try {
      final res = await apiProvider.post(
        'schools/manage/',
        data: {'name': name.trim(), 'code': code.trim(), 'is_active': isActive},
      );
      return SchoolModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<SchoolModel> updateSchool({
    required int id,
    String? name,
    String? code,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> payload = {};
      if (name != null) payload['name'] = name.trim();
      if (code != null) payload['code'] = code.trim();
      if (isActive != null) payload['is_active'] = isActive;

      final res = await apiProvider.patch('schools/manage/$id/', data: payload);
      return SchoolModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> createSchoolAdmin({
    required int schoolId,
    required String username,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'username': username.trim(),
        'password': password,
      };
      if (firstName != null && firstName.trim().isNotEmpty) {
        payload['first_name'] = firstName.trim();
      }
      if (lastName != null && lastName.trim().isNotEmpty) {
        payload['last_name'] = lastName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        payload['phone_number'] = phoneNumber.trim();
      }

      await apiProvider.post(
        'schools/manage/$schoolId/create-admin/',
        data: payload,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۲. مدیریت کادر و معلمان (SCHOOL_ADMIN) ====================
  Future<PaginatedResponse<StaffMemberModel>> getStaff({int page = 1}) async {
    try {
      final res = await apiProvider.get(
        'accounts/staff/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, StaffMemberModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<StaffMemberModel> createStaff({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
    bool isActive = true,
  }) async {
    try {
      final res = await apiProvider.post(
        'accounts/staff/',
        data: {
          'username': username.trim(),
          'password': password,
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
            'phone_number': phoneNumber.trim(),
          'role': role,
          'is_active': isActive,
        },
      );
      return StaffMemberModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<StaffMemberModel> updateStaff({
    required int id,
    required String username,
    String? password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
    required bool isActive,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'username': username.trim(),
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone_number': (phoneNumber != null && phoneNumber.trim().isNotEmpty)
            ? phoneNumber.trim()
            : null,
        'role': role,
        'is_active': isActive,
      };
      if (password != null && password.isNotEmpty) {
        payload['password'] = password;
      }

      final res = await apiProvider.patch('accounts/staff/$id/', data: payload);
      return StaffMemberModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await apiProvider.delete('accounts/staff/$id/');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۳. سال‌های تحصیلی (AcademicYear) ====================
  Future<PaginatedResponse<AcademicYearModel>> getAcademicYears({
    int page = 1,
  }) async {
    try {
      final res = await apiProvider.get(
        'schools/academic-years/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, AcademicYearModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<AcademicYearModel> createAcademicYear({
    required String title,
    required String startDate,
    required String endDate,
    required bool isCurrent,
  }) async {
    try {
      final res = await apiProvider.post(
        'schools/academic-years/',
        data: {
          'title': title.trim(),
          'start_date': startDate.trim(),
          'end_date': endDate.trim(),
          'is_current': isCurrent,
        },
      );
      return AcademicYearModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<AcademicYearModel> updateAcademicYear({
    required int id,
    String? title,
    String? startDate,
    String? endDate,
    bool? isCurrent,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title.trim();
      if (startDate != null) data['start_date'] = startDate.trim();
      if (endDate != null) data['end_date'] = endDate.trim();
      if (isCurrent != null) data['is_current'] = isCurrent;

      final res = await apiProvider.patch(
        'schools/academic-years/$id/',
        data: data,
      );
      return AcademicYearModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteAcademicYear(int id) async {
    try {
      await apiProvider.delete('schools/academic-years/$id/');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۴. پایه‌های تحصیلی (Grade) ====================
  Future<PaginatedResponse<GradeModel>> getGrades({int page = 1}) async {
    try {
      final res = await apiProvider.get(
        'schools/grades/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, GradeModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<GradeModel> createGrade({
    required String title,
    required int levelOrder,
  }) async {
    try {
      final res = await apiProvider.post(
        'schools/grades/',
        data: {'title': title.trim(), 'level_order': levelOrder},
      );
      return GradeModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteGrade(int id) async {
    try {
      await apiProvider.delete('schools/grades/$id/');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۵. کلاس‌ها (Classroom) ====================
  Future<PaginatedResponse<ClassroomModel>> getClassrooms({
    int page = 1,
    int? academicYearId,
    int? gradeId,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (academicYearId != null) params['academic_year'] = academicYearId;
      if (gradeId != null) params['grade'] = gradeId;
      if (isActive != null) params['is_active'] = isActive;

      final res = await apiProvider.get(
        'schools/classrooms/',
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(res.data, ClassroomModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ClassroomModel> createClassroom({
    required int academicYearId,
    required int gradeId,
    required String name,
    bool isActive = true,
  }) async {
    try {
      final res = await apiProvider.post(
        'schools/classrooms/',
        data: {
          'academic_year': academicYearId,
          'grade': gradeId,
          'name': name.trim(),
          'is_active': isActive,
        },
      );
      return ClassroomModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ClassroomModel> updateClassroom({
    required int id,
    int? academicYearId,
    int? gradeId,
    String? name,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (academicYearId != null) data['academic_year'] = academicYearId;
      if (gradeId != null) data['grade'] = gradeId;
      if (name != null) data['name'] = name.trim();
      if (isActive != null) data['is_active'] = isActive;

      final res = await apiProvider.patch(
        'schools/classrooms/$id/',
        data: data,
      );
      return ClassroomModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۶. برنامه هفتگی و تخصیص معلم (TeacherAssignment) ====================
  Future<PaginatedResponse<TeacherAssignmentModel>> getTeacherAssignments({
    int page = 1,
    int? classroomId,
    int? teacherId,
    int? dayOfWeek,
    int? sessionNumber,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (classroomId != null) params['classroom'] = classroomId;
      if (teacherId != null) params['teacher'] = teacherId;
      if (dayOfWeek != null) params['day_of_week'] = dayOfWeek;
      if (sessionNumber != null) params['session_number'] = sessionNumber;

      final res = await apiProvider.get(
        'schools/assignments/',
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(
        res.data,
        TeacherAssignmentModel.fromJson,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<TeacherAssignmentModel> createTeacherAssignment({
    required int teacherId,
    required int classroomId,
    required String subjectName,
    int? dayOfWeek,
    required int sessionNumber,
  }) async {
    try {
      final res = await apiProvider.post(
        'schools/assignments/',
        data: {
          'teacher': teacherId,
          'classroom': classroomId,
          'subject_name': subjectName.trim(),
          'day_of_week': dayOfWeek,
          'session_number': sessionNumber,
        },
      );
      return TeacherAssignmentModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteTeacherAssignment(int id) async {
    try {
      await apiProvider.delete('schools/assignments/$id/');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }
}
