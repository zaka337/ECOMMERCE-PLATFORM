import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
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
            // Load new fields, default if missing (for old data)
            gender: value['gender'] ?? 'Men',
            category: value['category'] ?? 'Jackets',
            storeOwnerId: value['storeOwnerId'] as String?,
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User must be authenticated to add products");
    }

    // For store owners, automatically set storeOwnerId
    final productToAdd = product.storeOwnerId == null
        ? Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl,
            gender: product.gender,
            category: product.category,
            storeOwnerId: user.uid, // Set current user as owner
          )
        : product;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productToAdd.toJson()),
      );

      if (response.statusCode >= 400) {
        throw Exception("Server Error: ${response.statusCode}.");
      }
      
      if (response.body.isEmpty || response.body == 'null') {
        throw Exception("Database returned empty response.");
      }
      
      final responseData = json.decode(response.body);
      
      String id;
      if (responseData is Map<String, dynamic> && responseData.containsKey('name')) {
        id = responseData['name'] as String;
      } else if (responseData is String) {
        id = responseData;
      } else {
        throw Exception("Database returned invalid data format.");
      }

      final newProduct = Product(
        id: id,
        name: productToAdd.name,
        description: productToAdd.description,
        price: productToAdd.price,
        imageUrl: productToAdd.imageUrl,
        gender: productToAdd.gender,
        category: productToAdd.category,
        storeOwnerId: productToAdd.storeOwnerId,
      );
      
      state = [...state, newProduct];
    } catch (e) {
      print("Error adding product: $e");
      rethrow; 
    }
  }

  // --- UPDATE ---
  Future<void> updateProduct(String id, Product newProduct) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User must be authenticated to update products");
    }

    final prodIndex = state.indexWhere((prod) => prod.id == id);
    if (prodIndex < 0) {
      throw Exception("Product not found");
    }

    final existingProduct = state[prodIndex];
    
    // Check if user owns this product (for store owners)
    if (existingProduct.storeOwnerId != null && existingProduct.storeOwnerId != user.uid) {
      throw Exception("You can only update your own products");
    }

    try {
      await http.patch(
        Uri.parse('$_baseUrl/$id.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newProduct.toJson()),
      );
      
      final updatedList = [...state];
      updatedList[prodIndex] = newProduct;
      state = updatedList;
    } catch (e) {
       print("Error updating product: $e");
       rethrow;
    }
  }

  // --- DELETE ---
  Future<void> deleteProduct(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User must be authenticated to delete products");
    }

    final existingProductIndex = state.indexWhere((prod) => prod.id == id);
    if (existingProductIndex < 0) {
      throw Exception("Product not found");
    }

    final existingProduct = state[existingProductIndex];
    
    // Check if user owns this product (for store owners)
    if (existingProduct.storeOwnerId != null && existingProduct.storeOwnerId != user.uid) {
      throw Exception("You can only delete your own products");
    }
    
    final tempState = [...state];
    tempState.removeAt(existingProductIndex);
    state = tempState;

    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id.json'));
      if (response.statusCode >= 400) {
        state = [...tempState]..insert(existingProductIndex, existingProduct);
        throw Exception("Could not delete product.");
      }
    } catch (e) {
      state = [...tempState]..insert(existingProductIndex, existingProduct);
      rethrow;
    }
  }

  // Get products for current store owner
  List<Product> getMyProducts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return state.where((product) => product.storeOwnerId == user.uid).toList();
  }
}