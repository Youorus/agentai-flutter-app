// services/offer_match_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/core/utils/api_client.dart';
import '/features/home/models/offer.dart';
import '/core/utils/api_exception.dart';
import '/core/utils/api_error_handler.dart';


class OfferMatchService {
  /// Retourne la liste des offres matchées à l'utilisateur connecté
  static Future<List<Offer>> getMyMatchedOffers() async {
    final response = await ApiClient().get(
      "/me/matched-offers", // <--- adapte si ton endpoint backend change
      auth: true,
    );
    if (response.statusCode != 200) {
      throw parseApiError(response);
    }
    final List<dynamic> data = jsonDecode(response.body);
    // Corrigé : on vérifie que chaque item est un Map avant le fromJson
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Offer.fromJson(json))
        .toList();
  }
}