class UserProfile {
  String username;
  String? city;
  double? latitude;
  double? longitude;
  List<String>? contractTypes;
  List<String>? jobTitles;
  List<String>? industries;
  List<String>? professionalStatus;
  bool jobAlertsActive;
  double? maxDistanceKm; // <-- Ajouté ici

  UserProfile({
    required this.username,
    this.city,
    this.latitude,
    this.longitude,
    this.contractTypes,
    this.jobTitles,
    this.industries,
    this.professionalStatus,
    this.jobAlertsActive = true,
    this.maxDistanceKm, // <-- Ajout ici
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    username: json['username'],
    city: json['city'],
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    contractTypes: (json['contract_types'] as List?)?.cast<String>(),
    jobTitles: (json['job_titles'] as List?)?.cast<String>(),
    industries: (json['industries'] as List?)?.cast<String>(),
    professionalStatus: (json['professional_status'] as List?)?.cast<String>(),
    jobAlertsActive: json['job_alerts_active'] ?? true,
    maxDistanceKm: json['max_distance_km']?.toDouble(), // <-- Ajout
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'contract_types': contractTypes,
    'job_titles': jobTitles,
    'industries': industries,
    'professional_status': professionalStatus,
    'job_alerts_active': jobAlertsActive,
    'max_distance_km': maxDistanceKm, // <-- Ajout
  };
}