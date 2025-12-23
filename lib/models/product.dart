class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String gender;    // New: 'Men' or 'Women'
  final String category;  // New: 'Jackets', 'Shoes', etc.
  final String? storeOwnerId; // Store owner's UID (null for admin products)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.gender = 'Men',       // Default for old items
    this.category = 'Jackets', // Default for old items
    this.storeOwnerId,         // Optional: null for existing products
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'gender': gender,
      'category': category,
    };
    if (storeOwnerId != null) {
      json['storeOwnerId'] = storeOwnerId!;
    }
    return json;
  }
}