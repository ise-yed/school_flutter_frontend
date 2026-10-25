class NotificationModel {
  final List<NotificationDoc> results;
  final int count;
  final String? next;
  final String? previous;
  final int page;
  final int pageSize;

  NotificationModel({
    required this.results,
    required this.count,
    this.next,
    this.previous,
    this.page = 1,
    this.pageSize = 20,
  });

  /// Aliases and getters for backward compatibility
  List<NotificationDoc> get docs => results;
  int get totalDocs => count;
  int get limit => pageSize;
  int get totalPages => (count / (pageSize > 0 ? pageSize : 20)).ceil();
  int get pagingCounter => ((page - 1) * pageSize) + 1;
  bool get hasPrevPage => previous != null || page > 1;
  bool get hasNextPage =>
      next != null || (page * (pageSize > 0 ? pageSize : 20) < count);
  int? get nextPage => hasNextPage ? page + 1 : null;
  int? get prevPage => page > 1 ? page - 1 : null;
  int get unseen => results.where((e) => !e.isRead).length;

  factory NotificationModel.fromJson(
    dynamic json, {
    int currentPage = 1,
    int limit = 20,
  }) {
    if (json is List) {
      final list = json
          .map((e) => NotificationDoc.fromJson(e as Map<String, dynamic>))
          .toList();
      return NotificationModel(
        results: list,
        count: list.length,
        page: currentPage,
        pageSize: limit,
      );
    }

    if (json is Map<String, dynamic>) {
      // DRF pagination standard: "results", "count", "next", "previous"
      if (json.containsKey('results') && json['results'] is List) {
        final rawList = json['results'] as List;
        final list = rawList
            .map((e) => NotificationDoc.fromJson(e as Map<String, dynamic>))
            .toList();
        final count = (json['count'] as num?)?.toInt() ?? list.length;
        final next = json['next'] as String?;
        final previous = json['previous'] as String?;

        return NotificationModel(
          results: list,
          count: count,
          next: next,
          previous: previous,
          page: currentPage,
          pageSize: limit,
        );
      }

      // Old / custom format: "docs"
      if (json.containsKey('docs') && json['docs'] is List) {
        final rawList = json['docs'] as List;
        final list = rawList
            .map((e) => NotificationDoc.fromJson(e as Map<String, dynamic>))
            .toList();
        return NotificationModel(
          results: list,
          count: (json['totalDocs'] as num?)?.toInt() ?? list.length,
          page: (json['page'] as num?)?.toInt() ?? currentPage,
          pageSize: (json['limit'] as num?)?.toInt() ?? limit,
          next: (json['hasNextPage'] == true) ? 'next' : null,
          previous: (json['hasPrevPage'] == true) ? 'prev' : null,
        );
      }
    }

    return NotificationModel(
      results: [],
      count: 0,
      page: currentPage,
      pageSize: limit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'count': count,
      'next': next,
      'previous': previous,
      'page': page,
      'pageSize': pageSize,
    };
  }
}

/// Single notification item mapping backend Notification model
class NotificationDoc {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final String? relatedObjectType;
  final String? relatedObjectId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationDoc({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    this.relatedObjectType,
    this.relatedObjectId,
    this.data,
    required this.createdAt,
  });

  /// Aliases for backward compatibility
  bool get seen => isRead;
  String get content => message;
  String get receiver => '';
  DateTime get updatedAt => readAt ?? createdAt;

  NotificationDoc copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? readAt,
    String? relatedObjectType,
    String? relatedObjectId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationDoc(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      relatedObjectType: relatedObjectType ?? this.relatedObjectType,
      relatedObjectId: relatedObjectId ?? this.relatedObjectId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationDoc.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return NotificationDoc(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: (json['type'] ?? 'default').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? json['content'] ?? '').toString(),
      isRead: json['is_read'] == true || json['seen'] == true,
      readAt: json['read_at'] != null ? parseDate(json['read_at']) : null,
      relatedObjectType: json['related_object_type']?.toString(),
      relatedObjectId: json['related_object_id']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'related_object_type': relatedObjectType,
      'related_object_id': relatedObjectId,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
