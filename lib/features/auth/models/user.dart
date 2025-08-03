class UserCreate {
  final String email;
  final String password;

  UserCreate({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
  };
}