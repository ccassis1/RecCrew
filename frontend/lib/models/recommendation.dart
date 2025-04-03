class Recommendation {
  final String id;
  final String name;
  final String city;
  final double rating;
  final String? category;
  final bool crewDiscount;
  final String? airline;

  Recommendation({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    this.category,
    this.crewDiscount = false,
    this.airline,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      name: json['business_name'],
      city: json['city'],
      rating: (json['rating'] as num).toDouble(),
      category: json['category'],
      crewDiscount: json['crew_discount'] ?? false,
      airline: json['airline'],
    );
  }
}
