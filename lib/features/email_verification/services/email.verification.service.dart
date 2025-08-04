import '/core/utils/api_client.dart';
import '/core/utils/api_error_handler.dart';

class VerificationEmailService {
  /// Renvoie le code à l’email de l’utilisateur connecté
 static Future<void> resendEmailCode() async {
  final response = await ApiClient().post(
    "/auth/resend-validation-code",
    auth: true,
  );
  if (response.statusCode != 200) {
    throw parseApiError(response);
  }
}

static Future<void> verifyEmailCode({
  required String code,
}) async {
  final response = await ApiClient().post(
    "/auth/verify-email",
    body: {"code": code},
    auth: true,
  );
  if (response.statusCode != 200) {
    throw parseApiError(response);
  }
}
}