class UserProfile {
  UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get initials {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory UserProfile.fromSupabase(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String?,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toSupabase() => {
        'display_name': displayName,
        'email': email,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
