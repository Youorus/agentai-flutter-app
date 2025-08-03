import '/core/utils/api_client.dart';
import '/core/utils/api_error_handler.dart';

class VerificationEmailService {
  // ... autres méthodes

  /// Envoie le code de validation à l’email utilisateur
  static Future<void> sendValidationCode(String email) async {
    final response = await ApiClient().post(
      "/auth/send-validation-code",
      body: {"email": email},
    );
    if (response.statusCode != 200) {
      throw parseApiError(response);
    }
  }

  /// Valide le code reçu par email
  static Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final response = await ApiClient().post(
      "/auth/verify-email",
      body: {"email": email, "code": code},
    );
    if (response.statusCode != 200) {
      throw parseApiError(response);
    }
  }
}