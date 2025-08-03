import '../models/user.dart';
import '../models/token.dart';
import '/core/utils/api_client.dart';
import '/core/utils/api_error_handler.dart';
import 'dart:convert';
import 'package:app/core/utils/token_storage.dart';

class AuthApi {
  // ===== Inscription classique =====
  static Future<Token> signup(UserCreate user) async {
    final response = await ApiClient().post(
      "/auth/signup",
      body: user.toJson(),
    );
    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      throw parseApiError(response);
    }
  }

  // ===== Connexion classique =====
  static Future<Token> login({required String email, required String password}) async {
    final response = await ApiClient().post(
      "/auth/login",
      body: {
        "email": email,
        "password": password,
      },
    );
    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      throw parseApiError(response);
    }
  }

  // ===== Connexion/inscription Google (mobile) =====
  static Future<Token> googleSignIn({required String idToken}) async {
    final response = await ApiClient().post(
      "/auth/google/mobile",
      body: {"id_token": idToken},
    );
    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      throw parseApiError(response);
    }
  }

  // ===== Connexion/inscription Facebook (mobile) =====
  static Future<Token> facebookSignIn({required String accessToken}) async {
    final response = await ApiClient().post(
      "/auth/facebook/mobile",
      body: {"access_token": accessToken},
    );
    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      throw parseApiError(response);
    }
  }

  // ===== Déconnexion =====
  static Future<void> logout() async {
    try {
      await ApiClient().get("/auth/logout");
    } catch (_) {
      // On ignore les erreurs réseau pour logout
    }
    await TokenStorage.deleteToken();
  }
}