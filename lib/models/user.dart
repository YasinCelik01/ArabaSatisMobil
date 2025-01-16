class User {
  final String username;
  final String email;
  final String password;

  User({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'Email': email,
      'PasswordHash': password,
    };
  }
}
