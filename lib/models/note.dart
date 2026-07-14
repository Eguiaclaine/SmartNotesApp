class Note {
  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.reminderAt,
    this.updatedAt,
    this.spaceId,
    this.isArchived = false,
    this.archivedAt,
    this.colorTag,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? reminderAt;
  final DateTime? updatedAt;
  final String? spaceId;
  final bool isArchived;
  final DateTime? archivedAt;
  final String? colorTag;

  bool get hasReminder => reminderAt != null && reminderAt!.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'reminderAt': reminderAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'spaceId': spaceId,
        'isArchived': isArchived,
        'archivedAt': archivedAt?.toIso8601String(),
        'colorTag': colorTag,
      };

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'reminder_at': reminderAt?.toIso8601String(),
        'updated_at': (updatedAt ?? createdAt).toIso8601String(),
        'space_id': spaceId,
        'is_archived': isArchived,
        'archived_at': archivedAt?.toIso8601String(),
        'color_tag': colorTag,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        reminderAt: json['reminderAt'] != null
            ? DateTime.parse(json['reminderAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        spaceId: json['spaceId'] as String?,
        isArchived: json['isArchived'] as bool? ?? false,
        archivedAt: json['archivedAt'] != null
            ? DateTime.parse(json['archivedAt'] as String)
            : null,
        colorTag: json['colorTag'] as String?,
      );

  factory Note.fromSupabase(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        reminderAt: json['reminder_at'] != null
            ? DateTime.parse(json['reminder_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        spaceId: json['space_id'] as String?,
        isArchived: json['is_archived'] as bool? ?? false,
        archivedAt: json['archived_at'] != null
            ? DateTime.parse(json['archived_at'] as String)
            : null,
        colorTag: json['color_tag'] as String?,
      );

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? reminderAt,
    DateTime? updatedAt,
    String? spaceId,
    bool? isArchived,
    DateTime? archivedAt,
    String? colorTag,
    bool clearReminder = false,
    bool clearSpace = false,
    bool clearColorTag = false,
    bool clearArchivedAt = false,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      updatedAt: updatedAt ?? this.updatedAt,
      spaceId: clearSpace ? null : (spaceId ?? this.spaceId),
      isArchived: isArchived ?? this.isArchived,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      colorTag: clearColorTag ? null : (colorTag ?? this.colorTag),
    );
  }
}
