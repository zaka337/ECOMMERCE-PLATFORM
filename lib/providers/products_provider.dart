import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

// Your Firebase Database URL
const String _baseUrl = 'https://satti-ecom-default-rtdb.asia-southeast1.firebasedatabase.app/products';

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super([]);

  // --- READ (Fetch) ---
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl.json'));
      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<Product> loadedProducts = [];
        data.forEach((key, value) {
          loadedProducts.add(Product(
            id: key,
            name: value['name'] ?? 'Unknown Artifact',
            description: value['description'] ?? '',
            price: (value['price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: value['imageUrl'] ?? '',
          ));
        });
        state = loadedProducts;
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // --- CREATE ---
  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      // Check for server errors
      if (response.statusCode >= 400) {
        throw Exception("Server Error: ${response.statusCode}. Check Firebase Rules.");
      }
      
      if (response.body.isEmpty || response.body == 'null') {
        throw Exception("Database returned empty response. Write operation might have failed.");
      }
      
      final responseData = json.decode(response.body);
      
      // Firebase Realtime Database POST returns {"name": "generated-key"}
      String id;
      if (responseData is Map<String, dynamic> && responseData.containsKey('name')) {
        id = responseData['name'] as String;
      } else if (responseData is String) {
        // Sometimes Firebase returns the key directly as a string
        id = responseData;
      } else {
        throw Exception("Database returned invalid data format. Write operation might have failed.");
      }

      final newProduct = Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      
      state = [...state, newProduct];
    } catch (e) {
      print("Error adding product: $e");
      rethrow; // Pass error to UI
    }
  }

  // --- UPDATE ---
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = state.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      try {
        final response = await http.patch(
          Uri.parse('$_baseUrl/$id.json'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newProduct.toJson()),
        );

        if (response.statusCode >= 400) {
           throw Exception("Could not update product.");
        }
        
        final updatedList = [...state];
        updatedList[prodIndex] = newProduct;
        state = updatedList;
      } catch (e) {
         print("Error updating product: $e");
         rethrow;
      }
    }
  }

  // --- DELETE ---
  Future<void> deleteProduct(String id) async {
    final existingProductIndex = state.indexWhere((prod) => prod.id == id);
    final existingProduct = state[existingProductIndex];
    
    // Optimistic update: remove from UI immediately
    final tempState = [...state];
    tempState.removeAt(existingProductIndex);
    state = tempState;

    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id.json'));
      if (response.statusCode >= 400) {
        // Rollback if failed
        state = [...tempState]..insert(existingProductIndex, existingProduct);
        throw Exception("Could not delete product.");
      }
    } catch (e) {
      state = [...tempState]..insert(existingProductIndex, existingProduct);
      rethrow;
    }
  }
}