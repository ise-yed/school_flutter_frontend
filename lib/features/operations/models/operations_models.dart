class AttendanceStatus {
  AttendanceStatus._();

  static const String present = 'PRESENT';
  static const String excusedAbsence = 'EXCUSED_ABSENCE';
  static const String unexcusedAbsence = 'UNEXCUSED_ABSENCE';
  static const String late = 'LATE';

  static String labelFa(String? status) {
    switch (status) {
      case present:
        return 'حاضر';
      case excusedAbsence:
        return 'غایب موجه';
      case unexcusedAbsence:
        return 'غایب غیرموجه';
      case late:
        return 'تأخیر';
      default:
        return 'ثبت‌نشده';
    }
  }
}

class DisciplineCategory {
  DisciplineCategory._();

  static const String behavioral = 'BEHAVIORAL';
  static const String tardiness = 'TARDINESS';
  static const String academic = 'ACADEMIC';
  static const String dressCode = 'DRESS_CODE';
  static const String merit = 'MERIT';
  static const String other = 'OTHER';

  static const Map<String, String> labelsFa = {
    behavioral: 'تذکر انضباطی / رفتاری',
    tardiness: 'تأخیر یا غیبت مکرر',
    academic: 'عدم انجام تکالیف / آموزشی',
    dressCode: 'پوشش و شئونات مدرسه',
    merit: 'تشویقی / اخلاقی و علمی',
    other: 'سایر موارد',
  };
}

class AttendanceSheetStudentItem {
  final int studentId;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String nationalCode;
  final int? attendanceId;
  String status;
  String note;

  AttendanceSheetStudentItem({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.nationalCode,
    this.attendanceId,
    required this.status,
    required this.note,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AttendanceSheetStudentItem.fromJson(Map<String, dynamic> json) {
    return AttendanceSheetStudentItem(
      studentId: (json['student_id'] as num).toInt(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      fatherName: (json['father_name'] ?? '').toString(),
      nationalCode: (json['national_code'] ?? '').toString(),
      attendanceId: (json['attendance_id'] as num?)?.toInt(),
      // اگر هنوز برای این زنگ وضعیتی ثبت نشده باشد، پیش‌فرض در فرم «حاضر» است تا ثبت سریع‌تر شود
      status: (json['status'] ?? AttendanceStatus.present).toString(),
      note: (json['note'] ?? '').toString(),
    );
  }
}

class AttendanceSheetModel {
  final int classroomId;
  final String classroomName;
  final String date;
  final int sessionNumber;
  final List<AttendanceSheetStudentItem> students;

  const AttendanceSheetModel({
    required this.classroomId,
    required this.classroomName,
    required this.date,
    required this.sessionNumber,
    required this.students,
  });

  factory AttendanceSheetModel.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'] as List? ?? [];
    return AttendanceSheetModel(
      classroomId: (json['classroom_id'] as num).toInt(),
      classroomName: (json['classroom_name'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      sessionNumber: (json['session_number'] as num?)?.toInt() ?? 0,
      students: rawStudents
          .whereType<Map>()
          .map(
            (e) => AttendanceSheetStudentItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}

class AttendanceRecordModel {
  final int id;
  final int student;
  final String studentFullName;
  final String fatherName;
  final String nationalCode;
  final int classroom;
  final String classroomName;
  final String date;
  final int sessionNumber;
  final String status;
  final String note;
  final int? recordedBy;
  final String? recordedByName;

  const AttendanceRecordModel({
    required this.id,
    required this.student,
    required this.studentFullName,
    required this.fatherName,
    required this.nationalCode,
    required this.classroom,
    required this.classroomName,
    required this.date,
    required this.sessionNumber,
    required this.status,
    required this.note,
    this.recordedBy,
    this.recordedByName,
  });

  String get sessionLabelFa =>
      sessionNumber == 0 ? 'روزانه' : 'زنگ $sessionNumber';

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: (json['id'] as num).toInt(),
      student: (json['student'] as num).toInt(),
      studentFullName: (json['student_full_name'] ?? '').toString(),
      fatherName: (json['father_name'] ?? '').toString(),
      nationalCode: (json['national_code'] ?? '').toString(),
      classroom: (json['classroom'] as num).toInt(),
      classroomName: (json['classroom_name'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      sessionNumber: (json['session_number'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? AttendanceStatus.present).toString(),
      note: (json['note'] ?? '').toString(),
      recordedBy: (json['recorded_by'] as num?)?.toInt(),
      recordedByName: json['recorded_by_name']?.toString(),
    );
  }
}

class DisciplinaryRecordModel {
  final int id;
  final int student;
  final String studentFullName;
  final String fatherName;
  final String nationalCode;
  final int? classroom;
  final String? classroomName;
  final String date;
  final String category;
  final String categoryDisplay;
  final String description;
  final int scoreImpact;
  final String? createdByName;
  final String? updatedByName;

  const DisciplinaryRecordModel({
    required this.id,
    required this.student,
    required this.studentFullName,
    required this.fatherName,
    required this.nationalCode,
    this.classroom,
    this.classroomName,
    required this.date,
    required this.category,
    required this.categoryDisplay,
    required this.description,
    required this.scoreImpact,
    this.createdByName,
    this.updatedByName,
  });

  factory DisciplinaryRecordModel.fromJson(Map<String, dynamic> json) {
    final cat = (json['category'] ?? DisciplineCategory.behavioral).toString();
    return DisciplinaryRecordModel(
      id: (json['id'] as num).toInt(),
      student: (json['student'] as num).toInt(),
      studentFullName: (json['student_full_name'] ?? '').toString(),
      fatherName: (json['father_name'] ?? '').toString(),
      nationalCode: (json['national_code'] ?? '').toString(),
      classroom: (json['classroom'] as num?)?.toInt(),
      classroomName: json['classroom_name']?.toString(),
      date: (json['date'] ?? '').toString(),
      category: cat,
      categoryDisplay:
          json['category_display']?.toString() ??
          DisciplineCategory.labelsFa[cat] ??
          cat,
      description: (json['description'] ?? '').toString(),
      scoreImpact: (json['score_impact'] as num?)?.toInt() ?? 0,
      createdByName: json['created_by_name']?.toString(),
      updatedByName: json['updated_by_name']?.toString(),
    );
  }
}

class AuditLogModel {
  final int id;
  final String? actorName;
  final String? actorRole;
  final String action;
  final String targetModel;
  final String targetId;
  final Map<String, dynamic> changes;
  final String? ipAddress;
  final DateTime? createdAt;

  const AuditLogModel({
    required this.id,
    this.actorName,
    this.actorRole,
    required this.action,
    required this.targetModel,
    required this.targetId,
    required this.changes,
    this.ipAddress,
    this.createdAt,
  });

  String get actionLabelFa {
    switch (action) {
      case 'CREATE':
        return 'ایجاد';
      case 'UPDATE':
        return 'ویرایش';
      case 'DELETE':
        return 'حذف';
      default:
        return action;
    }
  }

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: (json['id'] as num).toInt(),
      actorName: json['actor_name']?.toString(),
      actorRole: json['actor_role']?.toString(),
      action: (json['action'] ?? '').toString(),
      targetModel: (json['target_model'] ?? '').toString(),
      targetId: (json['target_id'] ?? '').toString(),
      changes: json['changes'] is Map
          ? Map<String, dynamic>.from(json['changes'] as Map)
          : {},
      ipAddress: json['ip_address']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class AnnouncementModel {
  final int id;
  final String title;
  final String body;
  final String targetType;
  final int? targetGrade;
  final String? targetGradeTitle;
  final int? targetClassroom;
  final String? targetClassroomName;
  final List<String> channels;
  final DateTime? createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetType,
    this.targetGrade,
    this.targetGradeTitle,
    this.targetClassroom,
    this.targetClassroomName,
    required this.channels,
    this.createdAt,
  });

  String get targetLabelFa {
    switch (targetType) {
      case 'GRADE':
        return 'پایه ${targetGradeTitle ?? ""}';
      case 'CLASSROOM':
        return 'کلاس ${targetClassroomName ?? ""}';
      case 'SCHOOL':
      default:
        return 'کل مدرسه';
    }
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      targetType: (json['target_type'] ?? 'SCHOOL').toString(),
      targetGrade: (json['target_grade'] as num?)?.toInt(),
      targetGradeTitle: json['target_grade_title']?.toString(),
      targetClassroom: (json['target_classroom'] as num?)?.toInt(),
      targetClassroomName: json['target_classroom_name']?.toString(),
      channels: (json['channels'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class NotificationDeliveryModel {
  final int id;
  final String channel;
  final String recipient;
  final String subject;
  final String status;
  final String errorMessage;
  final DateTime? sentAt;

  const NotificationDeliveryModel({
    required this.id,
    required this.channel,
    required this.recipient,
    required this.subject,
    required this.status,
    required this.errorMessage,
    this.sentAt,
  });

  factory NotificationDeliveryModel.fromJson(Map<String, dynamic> json) {
    return NotificationDeliveryModel(
      id: (json['id'] as num).toInt(),
      channel: (json['channel'] ?? '').toString(),
      recipient: (json['recipient'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      errorMessage: (json['error_message'] ?? '').toString(),
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString())
          : null,
    );
  }
}
