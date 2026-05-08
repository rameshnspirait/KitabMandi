class BookModel {
  final String id;
  final String title;
  final String price;
  final String location;
  final String sellerName;
  final String imageUrl;
  final String postedTime;

  BookModel({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.sellerName,
    required this.imageUrl,
    required this.postedTime,
  });
}
