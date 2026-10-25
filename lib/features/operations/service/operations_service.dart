import 'package:dio/dio.dart';

import '../../../core/utils/api_provider.dart';
import '../../../core/utils/app_error.dart';
import '../../schools/models/school_models.dart';
import '../models/operations_models.dart';

class OperationsService {
  Never _rethrow(DioException e) {
    if (e.error is AppException) throw e.error as AppException;
    throw AppException(AppErrorCode.unknown, serverMessage: e.message);
  }

  // ==================== ۱. حضور و غیاب (Attendance) ====================
  Future<AttendanceSheetModel> getAttendanceSheet({
    required int classroomId,
    required String date,
    required int sessionNumber,
  }) async {
    try {
      final res = await apiProvider.get(
        'attendance/sheet/',
        queryParameters: {
          'classroom': classroomId,
          'date': date.trim(),
          'session_number': sessionNumber,
        },
      );
      return AttendanceSheetModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<Map<String, dynamic>> bulkSubmitAttendance({
    required int classroomId,
    required String date,
    required int sessionNumber,
    bool defaultPresentForOthers = true,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      final res = await apiProvider.post(
        'attendance/bulk-submit/',
        data: {
          'classroom_id': classroomId,
          'date': date.trim(),
          'session_number': sessionNumber,
          'default_present_for_others': defaultPresentForOthers,
          'records': records,
        },
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<PaginatedResponse<AttendanceRecordModel>> getAttendanceRecords({
    int page = 1,
    int? classroomId,
    int? studentId,
    int? sessionNumber,
    String? status,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (classroomId != null) params['classroom'] = classroomId;
      if (studentId != null) params['student'] = studentId;
      if (sessionNumber != null) params['session_number'] = sessionNumber;
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (date != null && date.trim().isNotEmpty) params['date'] = date.trim();

      final res = await apiProvider.get('attendance/', queryParameters: params);
      return PaginatedResponse.fromJson(
        res.data,
        AttendanceRecordModel.fromJson,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<AttendanceRecordModel> updateAttendanceRecord({
    required int id,
    required String status,
    String? note,
  }) async {
    try {
      final res = await apiProvider.patch(
        'attendance/$id/',
        data: {'status': status, if (note != null) 'note': note.trim()},
      );
      return AttendanceRecordModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteAttendanceRecord(int id) async {
    try {
      await apiProvider.delete('attendance/$id/');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<List<AuditLogModel>> getAttendanceRecordHistory(int id) async {
    try {
      final res = await apiProvider.get('attendance/$id/history/');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((e) => AuditLogModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<PaginatedResponse<AuditLogModel>> getAttendanceAuditLogs({
    int page = 1,
  }) async {
    try {
      final res = await apiProvider.get(
        'attendance/audit-logs/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, AuditLogModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۲. پرونده انضباطی و تشویقی (Discipline) ====================
  Future<PaginatedResponse<DisciplinaryRecordModel>> getDisciplinaryRecords({
    int page = 1,
    int? classroomId,
    int? studentId,
    String? category,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (classroomId != null) params['classroom'] = classroomId;
      if (studentId != null) params['student'] = studentId;
      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }
      if (date != null && date.trim().isNotEmpty) params['date'] = date.trim();

      final res = await apiProvider.get('discipline/', queryParameters: params);
      return PaginatedResponse.fromJson(
        res.data,
        DisciplinaryRecordModel.fromJson,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<DisciplinaryRecordModel> createDisciplinaryRecord({
    required int studentId,
    int? classroomId,
    required String date,
    required String category,
    required String description,
    int scoreImpact = 0,
  }) async {
    try {
      final res = await apiProvider.post(
        'discipline/',
        data: {
          'student': studentId,
          if (classroomId != null) 'classroom': classroomId,
          'date': date.trim(),
          'category': category,
          'description': description.trim(),
          'score_impact': scoreImpact,
        },
      );
      return DisciplinaryRecordModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<DisciplinaryRecordModel> updateDisciplinaryRecord({
    required int id,
    String? category,
    String? description,
    int? scoreImpact,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (category != null) data['category'] = category;
      if (description != null) data['description'] = description.trim();
      if (scoreImpact != null) data['score_impact'] = scoreImpact;
      if (date != null) data['date'] = date.trim();

      final res = await apiProvider.patch('discipline/$id/', data: data);
      return DisciplinaryRecordModel.fromJson(
        Map<String, dynamic>.from(res.data),
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteDisciplinaryRecord(int id) async {
    try {
      await apiProvider.delete('discipline/$id/');
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<List<AuditLogModel>> getDisciplineRecordHistory(int id) async {
    try {
      final res = await apiProvider.get('discipline/$id/history/');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((e) => AuditLogModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<PaginatedResponse<AuditLogModel>> getDisciplineAuditLogs({
    int page = 1,
  }) async {
    try {
      final res = await apiProvider.get(
        'discipline/audit-logs/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, AuditLogModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  // ==================== ۳. اعلان‌های مدرسه و لاگ ارسال (Announcements) ====================
  Future<PaginatedResponse<AnnouncementModel>> getAnnouncements({
    int page = 1,
  }) async {
    try {
      final res = await apiProvider.get(
        'notifications/announcements/',
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(res.data, AnnouncementModel.fromJson);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String body,
    required String targetType,
    int? targetGradeId,
    int? targetClassroomId,
    required List<String> channels,
  }) async {
    try {
      final res = await apiProvider.post(
        'notifications/announcements/',
        data: {
          'title': title.trim(),
          'body': body.trim(),
          'target_type': targetType,
          if (targetType == 'GRADE' && targetGradeId != null)
            'target_grade': targetGradeId,
          if (targetType == 'CLASSROOM' && targetClassroomId != null)
            'target_classroom': targetClassroomId,
          'channels': channels,
        },
      );
      return AnnouncementModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<PaginatedResponse<NotificationDeliveryModel>> getDeliveries({
    int page = 1,
    int? announcementId,
    String? channel,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (announcementId != null) params['announcement'] = announcementId;
      if (channel != null && channel.isNotEmpty) params['channel'] = channel;
      if (status != null && status.isNotEmpty) params['status'] = status;

      final res = await apiProvider.get(
        'notifications/deliveries/',
        queryParameters: params,
      );
      return PaginatedResponse.fromJson(
        res.data,
        NotificationDeliveryModel.fromJson,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }
}
