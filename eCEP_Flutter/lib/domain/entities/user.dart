class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;
  final String role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatar,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      avatar: json['avatar'] ?? '',
      role: json['role'],
    );
  }

  String get fullName => '$firstName $lastName';

Map<String, dynamic> toJson() {
    return {
      'lastName': lastName,
      'firstName': firstName,
      'email': email,
      'avatar': avatar,
      'role': role
    };
  }
}
