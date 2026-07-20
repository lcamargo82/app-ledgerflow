class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.active,
  });

  final String id;
  final String email;
  final String name;
  final bool active;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? json['sub'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }
}
