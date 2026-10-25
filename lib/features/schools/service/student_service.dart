import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/utils/api_provider.dart';
import '../../../core/utils/app_error.dart';
import '../../schools/models/school_models.dart';
import '../models/student_models.dart';

class StudentService {
  Never _rethrow(DioException e) {
    if (e.error is AppException) throw e.error as AppException;
    throw AppException(AppErrorCode.unknown, serverMessage: e.message);
  }

  // ==================== ۱. دانش‌آموزان و جستجوی فازی ====================
  Future<PaginatedResponse<StudentModel>> getStudents({
    int page = 1,
    int? classroomId,
    bool? isActive,
    String? query,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (classroomId != null) params['classroom'] = classroomId;
      if (isActive != null) params['is_active'] = isActive;
      if (query != null && query.trim().isNotEmpty) {
        params['q'] = query.trim();
      }

      final String endpoint = (query != null && query.trim().isNotEmpty)
          ? 'students/search/'
          : 'students/';

      final res = await apiProvider.get(endpoint, queryParameters: params);
      return PaginatedResponse.fromJson(res.data, StudentModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<StudentModel> createStudent({
    required String firstName,
    required String lastName,
    String? fatherName,
    required String nationalCode,
    String? studentCode,
    bool isActive = true,
  }) async {
    try {
      final res = await apiProvider.post(
        'students/',
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'full_name': '${firstName.trim()} ${lastName.trim()}'.trim(),
          'father_name': (fatherName ?? '').trim(),
          'national_code': nationalCode.trim(),
          if (studentCode != null && studentCode.trim().isNotEmpty)
            'student_code': studentCode.trim(),
          'is_active': isActive,
        },
      );
      return StudentModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<StudentModel> updateStudent({
    required int id,
    String? firstName,
    String? lastName,
    String? fatherName,
    String? nationalCode,
    String? studentCode,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (firstName != null) data['first_name'] = firstName.trim();
      if (lastName != null) data['last_name'] = lastName.trim();
      if (firstName != null && lastName != null) {
        data['full_name'] = '${firstName.trim()} ${lastName.trim()}'.trim();
      }
      if (fatherName != null) data['father_name'] = fatherName.trim();
      if (nationalCode != null) data['national_code'] = nationalCode.trim();
      if (studentCode != null) data['student_code'] = studentCode.trim();
      if (isActive != null) data['is_active'] = isActive;

      final res = await apiProvider.patch('students/$id/', data: data);
      return StudentModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۲. ثبت‌نام کلاس (Enrollment) ====================
  Future<PaginatedResponse<EnrollmentModel>> getEnrollments({
    int page = 1,
    int? classroomId,
    int? academicYearId,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (classroomId != null) params['classroom'] = classroomId;
      if (academicYearId != null) params['academic_year'] = academicYearId;

      final res = await apiProvider.get(
        'students/enrollments/',
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(res.data, EnrollmentModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<EnrollmentModel> enrollStudent({
    required int studentId,
    required int classroomId,
  }) async {
    try {
      final res = await apiProvider.post(
        'students/enrollments/',
        data: {
          'student': studentId,
          'classroom': classroomId,
          'is_active': true,
        },
      );
      return EnrollmentModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۳. مدیریت اتصال اولیا (ParentStudentLink) ====================
  Future<PaginatedResponse<ParentStudentLinkModel>> getParentLinks({
    int page = 1,
    int? studentId,
    int? classroomId,
    bool? isVerified,
    String? nationalCode,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (studentId != null) params['student'] = studentId;
      if (classroomId != null) params['classroom'] = classroomId;
      if (isVerified != null) params['is_verified'] = isVerified;
      if (nationalCode != null && nationalCode.trim().isNotEmpty) {
        params['national_code'] = nationalCode.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        params['phone_number'] = phoneNumber.trim();
      }

      final res = await apiProvider.get(
        'students/parent-links/',
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(
        res.data,
        ParentStudentLinkModel.fromJson,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ParentStudentLinkModel> assignParentToStudent({
    int? studentId,
    String? studentNationalCode,
    required String phoneNumber,
    String relation = 'GUARDIAN',
    String? firstName,
    String? lastName,
  }) async {
    try {
      final res = await apiProvider.post(
        'students/parent-links/',
        data: {
          if (studentId != null) 'student_id': studentId,
          if (studentNationalCode != null &&
              studentNationalCode.trim().isNotEmpty)
            'student_national_code': studentNationalCode.trim(),
          'phone_number': phoneNumber.trim(),
          'relation': relation,
          if (firstName != null && firstName.trim().isNotEmpty)
            'first_name': firstName.trim(),
          if (lastName != null && lastName.trim().isNotEmpty)
            'last_name': lastName.trim(),
          'is_verified': true,
        },
      );
      return ParentStudentLinkModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ParentStudentLinkModel> verifyParentLink(int id) async {
    try {
      final res = await apiProvider.post('students/parent-links/$id/verify/');
      return ParentStudentLinkModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ParentStudentLinkModel> unverifyParentLink(int id) async {
    try {
      final res = await apiProvider.post('students/parent-links/$id/unverify/');
      return ParentStudentLinkModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ParentStudentLinkModel> changeParentPhone({
    required int linkId,
    required String phoneNumber,
    String? relation,
  }) async {
    try {
      final res = await apiProvider.post(
        'students/parent-links/$linkId/change-phone/',
        data: {
          'phone_number': phoneNumber.trim(),
          if (relation != null) 'relation': relation,
        },
      );
      return ParentStudentLinkModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteParentLink(int id) async {
    try {
      await apiProvider.delete('students/parent-links/$id/');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۴. ایمپورت ۳ مرحله‌ای اکسل ====================
  Future<ImportAnalyzeResult> analyzeExcel({
    required Uint8List fileBytes,
    required String fileName,
    String? sheetName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        if (sheetName != null && sheetName.isNotEmpty) 'sheet_name': sheetName,
      });

      final res = await apiProvider.post('imports/analyze/', data: formData);
      return ImportAnalyzeResult.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ImportPreviewResult> previewExcel({
    required int importLogId,
    required int classroomId,
    required Map<String, dynamic> mapping,
    String? sheetName,
    int? headerRow,
    Map<String, Map<String, String>>? rowOverrides,
  }) async {
    try {
      final res = await apiProvider.post(
        'imports/preview/',
        data: {
          'import_log_id': importLogId,
          'classroom_id': classroomId,
          'mapping': mapping,
          if (sheetName != null && sheetName.isNotEmpty)
            'sheet_name': sheetName,
          if (headerRow != null) 'header_row': headerRow,
          if (rowOverrides != null && rowOverrides.isNotEmpty)
            'row_overrides': rowOverrides,
        },
      );
      return ImportPreviewResult.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<ImportCommitResult> commitExcel({
    required int importLogId,
    required int classroomId,
    required Map<String, dynamic> mapping,
    bool allowClassroomTransfer = false,
    bool saveMapping = true,
    String mappingName = 'پیش‌فرض',
    String? sheetName,
    int? headerRow,
    Map<String, Map<String, String>>? rowOverrides,
  }) async {
    try {
      final res = await apiProvider.post(
        'imports/commit/',
        data: {
          'import_log_id': importLogId,
          'classroom_id': classroomId,
          'mapping': mapping,
          'allow_classroom_transfer': allowClassroomTransfer,
          'save_mapping': saveMapping,
          'mapping_name': mappingName,
          if (sheetName != null && sheetName.isNotEmpty)
            'sheet_name': sheetName,
          if (headerRow != null) 'header_row': headerRow,
          if (rowOverrides != null && rowOverrides.isNotEmpty)
            'row_overrides': rowOverrides,
        },
      );
      return ImportCommitResult.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<Map<String, dynamic>> importParentsExcel({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });
      final res = await apiProvider.post('imports/parents/', data: formData);
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<PaginatedResponse<ImportLogModel>> getImportLogs({
    int page = 1,
  }) async {
    try {
      final res = await apiProvider.get(
        'imports/logs/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, ImportLogModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }
}
