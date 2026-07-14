class Space {
  Space({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String emoji;
  final String colorHex;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'emoji': emoji,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'emoji': emoji,
        'color_hex': colorHex,
        'created_at': createdAt.toIso8601String(),
        'updated_at': (updatedAt ?? createdAt).toIso8601String(),
      };

  factory Space.fromJson(Map<String, dynamic> json) => Space(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '💗',
        colorHex: json['colorHex'] as String? ?? '#FF8FB8',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  factory Space.fromSupabase(Map<String, dynamic> json) => Space(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '💗',
        colorHex: json['color_hex'] as String? ?? '#FF8FB8',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Space copyWith({
    String? name,
    String? emoji,
    String? colorHex,
    DateTime? updatedAt,
  }) {
    return Space(
      id: id,
      userId: userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
