enum SpaceMood {
  focus,
  chill,
  boost,
  reset;

  String get label => switch (this) {
        SpaceMood.focus => 'Focus',
        SpaceMood.chill => 'Chill',
        SpaceMood.boost => 'Boost',
        SpaceMood.reset => 'Reset',
      };

  String get emoji => switch (this) {
        SpaceMood.focus => '🎯',
        SpaceMood.chill => '☁️',
        SpaceMood.boost => '⚡',
        SpaceMood.reset => '🌿',
      };

  static SpaceMood fromValue(String? value) {
    return SpaceMood.values.firstWhere(
      (mood) => mood.name == value,
      orElse: () => SpaceMood.focus,
    );
  }
}

class Space {
  Space({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.createdAt,
    this.updatedAt,
    this.motto,
    this.mood = SpaceMood.focus,
    this.weeklyGoal = 5,
    this.isFocus = false,
    this.sortOrder = 0,
  });

  final String id;
  final String userId;
  final String name;
  final String emoji;
  final String colorHex;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? motto;
  final SpaceMood mood;
  final int weeklyGoal;
  final bool isFocus;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'emoji': emoji,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'motto': motto,
        'mood': mood.name,
        'weeklyGoal': weeklyGoal,
        'isFocus': isFocus,
        'sortOrder': sortOrder,
      };

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'emoji': emoji,
        'color_hex': colorHex,
        'created_at': createdAt.toIso8601String(),
        'updated_at': (updatedAt ?? createdAt).toIso8601String(),
        'motto': motto,
        'mood': mood.name,
        'weekly_goal': weeklyGoal,
        'is_focus': isFocus,
        'sort_order': sortOrder,
      };

  /// Payload for UPDATE — does not rewrite id / user_id / created_at.
  Map<String, dynamic> toSupabaseUpdate() => {
        'name': name,
        'emoji': emoji,
        'color_hex': colorHex,
        'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
        'motto': motto,
        'mood': mood.name,
        'weekly_goal': weeklyGoal,
        'is_focus': isFocus,
        'sort_order': sortOrder,
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
        motto: json['motto'] as String?,
        mood: SpaceMood.fromValue(json['mood'] as String?),
        weeklyGoal: (json['weeklyGoal'] as num?)?.toInt() ?? 5,
        isFocus: json['isFocus'] as bool? ?? false,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
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
        motto: json['motto'] as String?,
        mood: SpaceMood.fromValue(json['mood'] as String?),
        weeklyGoal: (json['weekly_goal'] as num?)?.toInt() ?? 5,
        isFocus: json['is_focus'] as bool? ?? false,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );

  Space copyWith({
    String? name,
    String? emoji,
    String? colorHex,
    DateTime? updatedAt,
    String? motto,
    SpaceMood? mood,
    int? weeklyGoal,
    bool? isFocus,
    int? sortOrder,
    bool clearMotto = false,
  }) {
    return Space(
      id: id,
      userId: userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      motto: clearMotto ? null : (motto ?? this.motto),
      mood: mood ?? this.mood,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      isFocus: isFocus ?? this.isFocus,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class SpaceTemplate {
  const SpaceTemplate({
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.mood,
    required this.motto,
    required this.weeklyGoal,
  });

  final String name;
  final String emoji;
  final String colorHex;
  final SpaceMood mood;
  final String motto;
  final int weeklyGoal;

  static const presets = <SpaceTemplate>[
    SpaceTemplate(
      name: 'School',
      emoji: '🎓',
      colorHex: '#FF6B9D',
      mood: SpaceMood.focus,
      motto: 'Study smart, one note at a time',
      weeklyGoal: 7,
    ),
    SpaceTemplate(
      name: 'Work',
      emoji: '💼',
      colorHex: '#E85A8C',
      mood: SpaceMood.boost,
      motto: 'Ship ideas, chase progress',
      weeklyGoal: 5,
    ),
    SpaceTemplate(
      name: 'Ideas',
      emoji: '✨',
      colorHex: '#FF9EC4',
      mood: SpaceMood.chill,
      motto: 'Catch sparks before they fade',
      weeklyGoal: 4,
    ),
    SpaceTemplate(
      name: 'Personal',
      emoji: '🏠',
      colorHex: '#FF8FB8',
      mood: SpaceMood.reset,
      motto: 'Life notes & gentle plans',
      weeklyGoal: 3,
    ),
  ];
}
