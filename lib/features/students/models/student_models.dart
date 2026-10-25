class StudentModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String fatherName;
  final String nationalCode;
  final String? studentCode;
  final bool isActive;
  final int? currentClassroomId;
  final String? currentClassroomName;
  final String? currentGradeTitle;
  final double? similarity;

  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.fatherName,
    required this.nationalCode,
    this.studentCode,
    required this.isActive,
    this.currentClassroomId,
    this.currentClassroomName,
    this.currentGradeTitle,
    this.similarity,
  });

  String get displayName =>
      fullName.trim().isNotEmpty ? fullName : '$firstName $lastName'.trim();

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final fName = (json['first_name'] ?? '').toString();
    final lName = (json['last_name'] ?? '').toString();
    final full = (json['full_name'] ?? '').toString().trim();

    return StudentModel(
      id: (json['id'] as num).toInt(),
      firstName: fName,
      lastName: lName,
      fullName: full.isNotEmpty ? full : '$fName $lName'.trim(),
      fatherName: (json['father_name'] ?? '').toString(),
      nationalCode: (json['national_code'] ?? '').toString(),
      studentCode: json['student_code']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      currentClassroomId: (json['current_classroom_id'] as num?)?.toInt(),
      currentClassroomName: json['current_classroom_name']?.toString(),
      currentGradeTitle: json['current_grade_title']?.toString(),
      similarity: (json['similarity'] as num?)?.toDouble(),
    );
  }
}

class EnrollmentModel {
  final int id;
  final int student;
  final String studentFullName;
  final String studentNationalCode;
  final String fatherName;
  final int academicYear;
  final String academicYearTitle;
  final int classroom;
  final String classroomName;
  final bool isActive;

  const EnrollmentModel({
    required this.id,
    required this.student,
    required this.studentFullName,
    required this.studentNationalCode,
    required this.fatherName,
    required this.academicYear,
    required this.academicYearTitle,
    required this.classroom,
    required this.classroomName,
    required this.isActive,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: (json['id'] as num).toInt(),
      student: (json['student'] as num).toInt(),
      studentFullName: (json['student_full_name'] ?? '').toString(),
      studentNationalCode: (json['student_national_code'] ?? '').toString(),
      fatherName: (json['father_name'] ?? '').toString(),
      academicYear: (json['academic_year'] as num).toInt(),
      academicYearTitle: (json['academic_year_title'] ?? '').toString(),
      classroom: (json['classroom'] as num).toInt(),
      classroomName: (json['classroom_name'] ?? '').toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class ParentStudentLinkModel {
  final int id;
  final int parentUser;
  final String parentPhone;
  final String parentFirstName;
  final String parentLastName;
  final int student;
  final String studentFullName;
  final String studentNationalCode;
  final String fatherName;
  final String relation;
  final bool isVerified;

  const ParentStudentLinkModel({
    required this.id,
    required this.parentUser,
    required this.parentPhone,
    required this.parentFirstName,
    required this.parentLastName,
    required this.student,
    required this.studentFullName,
    required this.studentNationalCode,
    required this.fatherName,
    required this.relation,
    required this.isVerified,
  });

  String get relationDisplayFa {
    switch (relation) {
      case 'FATHER':
        return 'پدر';
      case 'MOTHER':
        return 'مادر';
      case 'GUARDIAN':
      default:
        return 'سرپرست';
    }
  }

  factory ParentStudentLinkModel.fromJson(Map<String, dynamic> json) {
    return ParentStudentLinkModel(
      id: (json['id'] as num).toInt(),
      parentUser: (json['parent_user'] as num).toInt(),
      parentPhone: (json['parent_phone'] ?? '').toString(),
      parentFirstName: (json['parent_first_name'] ?? '').toString(),
      parentLastName: (json['parent_last_name'] ?? '').toString(),
      student: (json['student'] as num).toInt(),
      studentFullName: (json['student_full_name'] ?? '').toString(),
      studentNationalCode: (json['student_national_code'] ?? '').toString(),
      fatherName: (json['father_name'] ?? '').toString(),
      relation: (json['relation'] ?? 'GUARDIAN').toString(),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class ImportAnalyzeResult {
  final int importLogId;
  final List<String> sheets;
  final String selectedSheet;
  final int guessedHeaderRow;
  final List<String> columns;
  final Map<String, dynamic> suggestedMapping;
  final List<Map<String, dynamic>> sampleRows;
  final int? suggestedClassroomId;
  final String? suggestedClassroomName;

  const ImportAnalyzeResult({
    required this.importLogId,
    required this.sheets,
    required this.selectedSheet,
    required this.guessedHeaderRow,
    required this.columns,
    required this.suggestedMapping,
    required this.sampleRows,
    this.suggestedClassroomId,
    this.suggestedClassroomName,
  });

  factory ImportAnalyzeResult.fromJson(Map<String, dynamic> json) {
    final suggestedCls = json['suggested_classroom'] as Map?;
    return ImportAnalyzeResult(
      importLogId: (json['import_log_id'] as num).toInt(),
      sheets: (json['sheets'] as List? ?? []).map((e) => e.toString()).toList(),
      selectedSheet: (json['selected_sheet'] ?? '').toString(),
      guessedHeaderRow: (json['guessed_header_row'] as num?)?.toInt() ?? 1,
      columns: (json['columns'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      suggestedMapping: Map<String, dynamic>.from(
        json['suggested_mapping'] as Map? ?? {},
      ),
      sampleRows: (json['sample_rows'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      suggestedClassroomId: (suggestedCls?['id'] as num?)?.toInt(),
      suggestedClassroomName: suggestedCls?['name']?.toString(),
    );
  }
}

class ImportPreviewResult {
  final int importLogId;
  final int classroomId;
  final String classroomName;
  final int totalRows;
  final int validCount;
  final int errorCount;
  final int warningCount;
  final List<Map<String, dynamic>> warnings;
  final List<Map<String, dynamic>> errors;
  final List<Map<String, dynamic>> newStudents;
  final List<Map<String, dynamic>> existingStudents;
  final List<Map<String, dynamic>> missingFromFileStudents;

  const ImportPreviewResult({
    required this.importLogId,
    required this.classroomId,
    required this.classroomName,
    required this.totalRows,
    required this.validCount,
    required this.errorCount,
    required this.warningCount,
    required this.warnings,
    required this.errors,
    required this.newStudents,
    required this.existingStudents,
    required this.missingFromFileStudents,
  });

  bool get hasTransferCandidates =>
      existingStudents.any((s) => s['requires_classroom_transfer'] == true);

  factory ImportPreviewResult.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parseMapList(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return ImportPreviewResult(
      importLogId: (json['import_log_id'] as num).toInt(),
      classroomId: (json['classroom_id'] as num).toInt(),
      classroomName: (json['classroom_name'] ?? '').toString(),
      totalRows: (json['total_rows'] as num?)?.toInt() ?? 0,
      validCount: (json['valid_count'] as num?)?.toInt() ?? 0,
      errorCount: (json['error_count'] as num?)?.toInt() ?? 0,
      warningCount: (json['warning_count'] as num?)?.toInt() ?? 0,
      warnings: parseMapList(json['warnings']),
      errors: parseMapList(json['errors']),
      newStudents: parseMapList(json['new_students']),
      existingStudents: parseMapList(json['existing_students']),
      missingFromFileStudents: parseMapList(json['missing_from_file_students']),
    );
  }
}

class ImportCommitResult {
  final int importLogId;
  final String status;
  final int totalRows;
  final int createdCount;
  final int updatedCount;
  final int errorCount;
  final int skippedTransfersCount;

  const ImportCommitResult({
    required this.importLogId,
    required this.status,
    required this.totalRows,
    required this.createdCount,
    required this.updatedCount,
    required this.errorCount,
    required this.skippedTransfersCount,
  });

  factory ImportCommitResult.fromJson(Map<String, dynamic> json) {
    return ImportCommitResult(
      importLogId: (json['import_log_id'] as num).toInt(),
      status: (json['status'] ?? '').toString(),
      totalRows: (json['total_rows'] as num?)?.toInt() ?? 0,
      createdCount: (json['created_count'] as num?)?.toInt() ?? 0,
      updatedCount: (json['updated_count'] as num?)?.toInt() ?? 0,
      errorCount: (json['error_count'] as num?)?.toInt() ?? 0,
      skippedTransfersCount:
          (json['skipped_transfers_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ImportLogModel {
  final int id;
  final String originalFilename;
  final int? targetClassroom;
  final String? classroomName;
  final String status;
  final int totalRows;
  final int createdCount;
  final int updatedCount;
  final int errorCount;
  final DateTime? createdAt;

  const ImportLogModel({
    required this.id,
    required this.originalFilename,
    this.targetClassroom,
    this.classroomName,
    required this.status,
    required this.totalRows,
    required this.createdCount,
    required this.updatedCount,
    required this.errorCount,
    this.createdAt,
  });

  factory ImportLogModel.fromJson(Map<String, dynamic> json) {
    return ImportLogModel(
      id: (json['id'] as num).toInt(),
      originalFilename: (json['original_filename'] ?? '').toString(),
      targetClassroom: (json['target_classroom'] as num?)?.toInt(),
      classroomName: json['classroom_name']?.toString(),
      status: (json['status'] ?? '').toString(),
      totalRows: (json['total_rows'] as num?)?.toInt() ?? 0,
      createdCount: (json['created_count'] as num?)?.toInt() ?? 0,
      updatedCount: (json['updated_count'] as num?)?.toInt() ?? 0,
      errorCount: (json['error_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
