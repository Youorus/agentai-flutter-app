// lib/models/secteur_emploi.dart
class SecteurEmploi {
  final String secteur;
  final List<String> motsCles;

  SecteurEmploi({required this.secteur, required this.motsCles});

  factory SecteurEmploi.fromJson(Map<String, dynamic> json) {
    return SecteurEmploi(
      secteur: json['secteur'],
      motsCles: List<String>.from(json['mots_cles']),
    );
  }
}