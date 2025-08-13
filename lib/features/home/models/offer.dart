class Offer {
  final int id;
  final String source;
  final String url;
  final String title;
  final String? companyDescription;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? publishedAt;
  final String? contractType;
  final String? description;
  final String? secteur;

  Offer({
    required this.id,
    required this.source,
    required this.url,
    required this.title,
    this.companyDescription,
    this.location,
    this.latitude,
    this.longitude,
    this.publishedAt,
    this.contractType,
    this.description,
    this.secteur,
  });
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      source: json['source'],
      url: json['url'],
      title: json['title'],
      companyDescription: json['companyDescription'] ?? json['company_description'],
      location: json['location'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      publishedAt: json['publishedAt'] ?? json['published_at'],
      contractType: json['contractType'] ?? json['contract_type'],
      description: json['description'],
      secteur: json['secteur'],
    );
  }
}