// models/token.dart

class Token {
  final String accessToken;
  final String tokenType;
  final bool isEmailVerified;
  final String email;

  Token({
    required this.accessToken,
    required this.isEmailVerified,
    required this.email,
    this.tokenType = "bearer",
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      tokenType: json['token_type'] ?? "bearer",
      isEmailVerified: json['is_email_verified'] == true,
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "token_type": tokenType,
    "is_email_verified": isEmailVerified,
    "email": email,
  };
}