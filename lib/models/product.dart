class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final List<String> sizes;
  final List<String> colors;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.sizes,
    required this.colors,
  });
}
