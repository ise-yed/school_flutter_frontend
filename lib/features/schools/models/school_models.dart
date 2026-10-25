class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginatedResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory PaginatedResponse.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    if (json is Map<String, dynamic> && json['results'] is List) {
      final list = (json['results'] as List)
          .whereType<Map>()
          .map((e) => fromJsonT(Map<String, dynamic>.from(e)))
          .toList();
      return PaginatedResponse(
        count: (json['count'] as num?)?.toInt() ?? list.length,
        next: json['next']?.toString(),
        previous: json['previous']?.toString(),
        results: list,
      );
    }
    if (json is List) {
      final list = json
          .whereType<Map>()
          .map((e) => fromJsonT(Map<String, dynamic>.from(e)))
          .toList();
      return PaginatedResponse(count: list.length, results: list);
    }
    return const PaginatedResponse(count: 0, results: []);
  }
}

class SchoolModel {
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final DateTime? createdAt;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.createdAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class StaffMemberModel {
  final int id;
  final String username;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final String role;
  final bool isActive;

  const StaffMemberModel({
    required this.id,
    required this.username,
    this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
  });

  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : username;
  }

  String get roleDisplayFa =>
      role == 'SCHOOL_ADMIN' ? 'کادر آموزشی / ادمین' : 'معلم';

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    return StaffMemberModel(
      id: (json['id'] as num).toInt(),
      username: (json['username'] ?? '').toString(),
      phoneNumber: json['phone_number']?.toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      role: (json['role'] ?? 'TEACHER').toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class AcademicYearModel {
  final int id;
  final String title;
  final String startDate; // فرمت شمسی YYYY-MM-DD
  final String endDate; // فرمت شمسی YYYY-MM-DD
  final bool isCurrent;

  const AcademicYearModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}

class GradeModel {
  final int id;
  final String title;
  final int levelOrder;

  const GradeModel({
    required this.id,
    required this.title,
    required this.levelOrder,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      levelOrder: (json['level_order'] as num?)?.toInt() ?? 1,
    );
  }
}

class ClassroomModel {
  final int id;
  final int academicYear;
  final String academicYearTitle;
  final int grade;
  final String gradeTitle;
  final String name;
  final bool isActive;

  const ClassroomModel({
    required this.id,
    required this.academicYear,
    required this.academicYearTitle,
    required this.grade,
    required this.gradeTitle,
    required this.name,
    required this.isActive,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: (json['id'] as num).toInt(),
      academicYear: (json['academic_year'] as num).toInt(),
      academicYearTitle: (json['academic_year_title'] ?? '').toString(),
      grade: (json['grade'] as num).toInt(),
      gradeTitle: (json['grade_title'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class TeacherAssignmentModel {
  final int id;
  final int teacher;
  final String teacherName;
  final int classroom;
  final String classroomName;
  final String gradeTitle;
  final String subjectName;
  final int? dayOfWeek;
  final String? dayOfWeekDisplay;
  final int sessionNumber;

  const TeacherAssignmentModel({
    required this.id,
    required this.teacher,
    required this.teacherName,
    required this.classroom,
    required this.classroomName,
    required this.gradeTitle,
    required this.subjectName,
    this.dayOfWeek,
    this.dayOfWeekDisplay,
    required this.sessionNumber,
  });

  static const Map<int, String> persianWeekDays = {
    0: 'شنبه',
    1: 'یکشنبه',
    2: 'دوشنبه',
    3: 'سه‌شنبه',
    4: 'چهارشنبه',
    5: 'پنجشنبه',
    6: 'جمعه',
  };

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> json) {
    final int? day = (json['day_of_week'] as num?)?.toInt();
    return TeacherAssignmentModel(
      id: (json['id'] as num).toInt(),
      teacher: (json['teacher'] as num).toInt(),
      teacherName: (json['teacher_name'] ?? '').toString(),
      classroom: (json['classroom'] as num).toInt(),
      classroomName: (json['classroom_name'] ?? '').toString(),
      gradeTitle: (json['grade_title'] ?? '').toString(),
      subjectName: (json['subject_name'] ?? '').toString(),
      dayOfWeek: day,
      dayOfWeekDisplay:
          json['day_of_week_display']?.toString() ??
          (day != null ? persianWeekDays[day] : 'همه روزها'),
      sessionNumber: (json['session_number'] as num?)?.toInt() ?? 1,
    );
  }
}
