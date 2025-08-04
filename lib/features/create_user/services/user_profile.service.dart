// lib/services/user_profile_service.dart
import 'dart:convert';
import '/core/utils/api_client.dart';
import '../models/user_profile.dart';

class UserProfileService {
  // PATCH un champ spécifique du profil
  static Future<UserProfile> patchProfileField(
    String field,
    dynamic value,
  ) async {
    final body = {field: value};
    final response = await ApiClient().patch(
      "/profiles/update",
      body: body,
      auth: true,
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour du profil');
    }
  }
}