import 'dart:convert';
import 'api_exception.dart';
import 'package:http/http.dart' as http;

/// Parse la réponse d'erreur HTTP en ApiException.
/// Loggue automatiquement le détail en console.
ApiException parseApiError(http.Response response) {
  String errorMsg = 'Erreur inconnue';
  final status = response.statusCode;
  final body = response.body;

  // Log de base
  print("❌ [API ERROR] Status: $status\nBody: $body");

  try {
    final decoded = jsonDecode(body);

    // Cas : message simple dans 'detail'
    if (decoded is Map && decoded['detail'] != null) {
      errorMsg = decoded['detail'].toString();
    }
    // Cas : message simple dans 'message'
    else if (decoded is Map && decoded['message'] != null) {
      errorMsg = decoded['message'].toString();
    }
    // Cas : Django REST Framework, erreurs de champs
    else if (decoded is Map && decoded['errors'] is List && decoded['errors'].isNotEmpty) {
      errorMsg = decoded['errors'].join('\n');
    }
    // Cas : dictionnaire d’erreurs par champ
    else if (decoded is Map && decoded.isNotEmpty) {
      // Ex : {"email": ["Déjà utilisé"], ...}
      final first = decoded.values.first;
      if (first is List && first.isNotEmpty) {
        errorMsg = first.first.toString();
      } else {
        errorMsg = first.toString();
      }
    }
    // Cas : juste une string
    else if (decoded is String) {
      errorMsg = decoded;
    }
  } catch (e) {
    print("❗️ [API ERROR] Erreur de parsing JSON: $e");
    // Si le parsing rate, fallback sur reasonPhrase ou body
    if (response.reasonPhrase != null && response.reasonPhrase!.isNotEmpty) {
      errorMsg = response.reasonPhrase!;
    } else if (body.isNotEmpty) {
      errorMsg = body;
    }
  }

  return ApiException(errorMsg, statusCode: status);
}