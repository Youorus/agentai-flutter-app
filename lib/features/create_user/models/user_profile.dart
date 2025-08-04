// lib/models/user_profile.dart

class UserProfile {
  String username;
  String? city;
  double? latitude;
  double? longitude;
  List<String>? contractTypes;
  List<String>? jobTitles;
  List<String>? industries;
  List<String>? professionalStatus; // <--- Correction ICI !
  bool jobAlertsActive;

  UserProfile({
    required this.username,
    this.city,
    this.latitude,
    this.longitude,
    this.contractTypes,
    this.jobTitles,
    this.industries,
    this.professionalStatus, // <--- Correction ICI !
    this.jobAlertsActive = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    username: json['username'],
    city: json['city'],
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    contractTypes: (json['contract_types'] as List?)?.cast<String>(),
    jobTitles: (json['job_titles'] as List?)?.cast<String>(),
    industries: (json['industries'] as List?)?.cast<String>(),
      professionalStatus: (json['professional_status'] as List?)?.cast<String>(), // <-- Correction ICI !
    jobAlertsActive: json['job_alerts_active'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'contract_types': contractTypes,
    'job_titles': jobTitles,
    'industries': industries,
    'professional_status': professionalStatus, // <-- Correction ICI !
    'job_alerts_active': jobAlertsActive,
  };
}