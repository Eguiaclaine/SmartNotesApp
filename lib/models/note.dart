class Note {
  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.reminderAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? reminderAt;
  final DateTime? updatedAt;

  bool get hasReminder => reminderAt != null && reminderAt!.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'reminderAt': reminderAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'reminder_at': reminderAt?.toIso8601String(),
        'updated_at': (updatedAt ?? createdAt).toIso8601String(),
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
      );

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? reminderAt,
    DateTime? updatedAt,
    bool clearReminder = false,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
