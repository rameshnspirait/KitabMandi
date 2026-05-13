class ListingModel {
  final String id;
  final String title;
  final int price;
  final String category;
  final String educationType;
  final String? className;
  final String? degree;
  final String? year;
  final String condition;
  final List<String> images;
  final bool? isBoosted;
  final bool? isSold;

  final Map<String, dynamic> location;
  final Map<String, dynamic> seller;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  ListingModel({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.educationType,
    this.className,
    this.degree,
    this.year,
    required this.condition,
    required this.images,
    required this.location,
    required this.seller,
    this.createdAt,
    this.updatedAt,
    this.isBoosted,
    this.isSold,
  });

  /// 🔥 FROM FIRESTORE
  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'] ?? "",
      title: map['title'] ?? "",
      price: map['price'] ?? 0,
      category: map['category'] ?? "",
      educationType: map['educationType'] ?? "",
      className: map['class'],
      degree: map['degree'],
      year: map['year'],
      condition: map['condition'] ?? "",
      images: List<String>.from(map['images'] ?? []),
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      seller: Map<String, dynamic>.from(map['seller'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : null,
      isBoosted: map['isBoosted'] ?? false,
      isSold: map['isSold'] ?? false,
    );
  }

  /// 🔥 TO MAP (optional)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "price": price,
      "category": category,
      "educationType": educationType,
      "class": className,
      "degree": degree,
      "year": year,
      "condition": condition,
      "images": images,
      "location": location,
      "seller": seller,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "isBoosted": isBoosted,
      "isSold": isSold,
    };
  }
}
