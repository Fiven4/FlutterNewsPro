class UserModel {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String? avatarPath;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio = 'Привет! Я использую это приложение.',
    this.avatarPath,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      avatarPath: json['avatarPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'avatarPath': avatarPath,
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? avatarPath,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}