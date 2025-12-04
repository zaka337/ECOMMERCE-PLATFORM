import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

final productsProvider = Provider<List<Product>>((ref) {
  return [
    Product(
      id: '1',
      name: 'Classic Denim Jacket',
      imageUrl: 'https://via.placeholder.com/300x300?text=Denim+Jacket',
      price: 89.99,
      rating: 4.5,
      sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Blue', 'Black', 'White'],
    ),
    Product(
      id: '2',
      name: 'Urban Hoodie',
      imageUrl: 'https://via.placeholder.com/300x300?text=Urban+Hoodie',
      price: 59.99,
      rating: 4.8,
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Gray', 'Navy', 'Black', 'Red'],
    ),
    Product(
      id: '3',
      name: 'Wool Long Coat',
      imageUrl: 'https://via.placeholder.com/300x300?text=Wool+Coat',
      price: 149.99,
      rating: 4.2,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Charcoal', 'Camel', 'Black'],
    ),
    Product(
      id: '4',
      name: 'Premium T-Shirt',
      imageUrl: 'https://via.placeholder.com/300x300?text=T-Shirt',
      price: 29.99,
      rating: 4.6,
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['White', 'Black', 'Navy', 'Green'],
    ),
  ];
});
