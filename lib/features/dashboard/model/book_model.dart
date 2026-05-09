class BookModel {
  final String id;
  final String title;
  final String price;
  final String location;
  final String sellerName;
  final List<String> images;
  final String postedTime;
  final bool isBoosted;

  BookModel({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.sellerName,
    required this.images,
    required this.postedTime,
    this.isBoosted = false,
  });
}
