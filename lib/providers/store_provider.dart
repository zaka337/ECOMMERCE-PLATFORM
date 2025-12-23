import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/store.dart';

const String _baseUrl = 'https://satti-ecom-default-rtdb.asia-southeast1.firebasedatabase.app/stores';

final storeProvider = StateNotifierProvider<StoreNotifier, Store?>((ref) {
  return StoreNotifier();
});

class StoreNotifier extends StateNotifier<Store?> {
  StoreNotifier() : super(null);

  // Check if current user has a store
  Future<void> loadUserStore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = null;
      return;
    }

    try {
      // Firebase Realtime Database query - need to use proper query format
      // Note: For this to work, you need to create an index on 'ownerId' in Firebase Console
      final encodedUid = Uri.encodeComponent('"${user.uid}"');
      final response = await http.get(
        Uri.parse('$_baseUrl.json?orderBy="ownerId"&equalTo=$encodedUid')
      );
      
      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.isNotEmpty) {
          final entry = data.entries.first;
          state = Store.fromJson(entry.key, entry.value as Map<String, dynamic>);
        } else {
          state = null;
        }
      } else {
        state = null;
      }
    } catch (e) {
      print("Error loading store: $e");
      state = null;
    }
  }

  // Create a new store
  Future<String> createStore({
    required String storeName,
    required String ownerName,
    required String email,
    required String phone,
    required String address,
    required String description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    try {
      final storeData = {
        'ownerId': user.uid,
        'storeName': storeName,
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
        'address': address,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(storeData),
      );

      if (response.statusCode >= 400) {
        throw Exception("Failed to create store: ${response.statusCode}");
      }

      final responseData = json.decode(response.body);
      String storeId;
      
      if (responseData is Map<String, dynamic> && responseData.containsKey('name')) {
        storeId = responseData['name'] as String;
      } else if (responseData is String) {
        storeId = responseData;
      } else {
        throw Exception("Invalid response format");
      }

      final newStore = Store(
        id: storeId,
        ownerId: user.uid,
        storeName: storeName,
        ownerName: ownerName,
        email: email,
        phone: phone,
        address: address,
        description: description,
        createdAt: DateTime.now(),
      );

      state = newStore;
      return storeId;
    } catch (e) {
      print("Error creating store: $e");
      rethrow;
    }
  }

  // Update store
  Future<void> updateStore(Store store) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/${store.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(store.toJson()),
      );

      if (response.statusCode >= 400) {
        throw Exception("Failed to update store");
      }

      state = store;
    } catch (e) {
      print("Error updating store: $e");
      rethrow;
    }
  }
}

