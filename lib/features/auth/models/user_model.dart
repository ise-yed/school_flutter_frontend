class UserRole {
  UserRole._();

  static const String superuser = 'SUPERUSER';
  static const String schoolAdmin = 'SCHOOL_ADMIN';
  static const String teacher = 'TEACHER';
  static const String parent = 'PARENT';
}

class SchoolOptionModel {
  final int id;
  final String name;

  const SchoolOptionModel({required this.id, required this.name});

  factory SchoolOptionModel.fromJson(Map<String, dynamic> json) {
    return SchoolOptionModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class UserModel {
  String? id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? fullName;
  bool? isVerified;
  bool? isActive;
  String? role;
  int? schoolId;

  String? avatar;
  String? name;
  String? phoneNumber;

  String? address;
  String? firebaseToken;
  DateTime? subscriptionPurchaseDate;
  DateTime? subscriptionExpireDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.isVerified,
    this.isActive,
    this.role,
    this.schoolId,
    this.avatar,
    this.name,
    this.phoneNumber,
    this.address,
    this.firebaseToken,
    this.subscriptionPurchaseDate,
    this.subscriptionExpireDate,
    this.createdAt,
    this.updatedAt,
  });

  bool get isSuperuser => role == UserRole.superuser;
  bool get isSchoolAdmin => role == UserRole.schoolAdmin;
  bool get isTeacher => role == UserRole.teacher;
  bool get isParent => role == UserRole.parent;

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    final combined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (combined.isNotEmpty) return combined;
    if (username != null && username!.trim().isNotEmpty) return username!;
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      return phoneNumber!;
    }
    return 'کاربر سامانه';
  }

  String get roleDisplayFa {
    switch (role) {
      case UserRole.superuser:
        return 'مدیر سیستم';
      case UserRole.schoolAdmin:
        return 'کادر آموزشی مدرسه';
      case UserRole.teacher:
        return 'معلم';
      case UserRole.parent:
        return 'ولی دانش‌آموز';
      default:
        return '';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final String? fName =
        json['first_name']?.toString() ?? json['firstName']?.toString();
    final String? lName =
        json['last_name']?.toString() ?? json['lastName']?.toString();
    String? full =
        json['full_name']?.toString() ?? json['fullName']?.toString();
    if ((full == null || full.trim().isEmpty) &&
        (fName != null || lName != null)) {
      full = '${fName ?? ''} ${lName ?? ''}'.trim();
    }

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      firstName: fName,
      lastName: lName,
      fullName: full,
      isVerified: json['is_verified'] as bool? ?? json['isVerified'] as bool?,
      isActive: json['is_active'] as bool? ?? true,
      role: json['role']?.toString(),
      schoolId:
          (json['school_id'] as num?)?.toInt() ??
          (json['schoolId'] as num?)?.toInt(),
      avatar: json['avatar']?.toString(),
      name: full ?? json['name']?.toString(),
      phoneNumber:
          json['phone_number']?.toString() ?? json['phoneNumber']?.toString(),
      address: json['address']?.toString(),
      firebaseToken: json['firebaseToken']?.toString(),
      createdAt: (json['created_at'] != null)
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: (json['updated_at'] != null)
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'is_verified': isVerified,
      'is_active': isActive,
      'role': role,
      'school_id': schoolId,
      'avatar': avatar,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'firebaseToken': firebaseToken,
    };
  }
}
