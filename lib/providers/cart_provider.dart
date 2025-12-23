import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart({
    required Product product,
    required String size,
    required String color,
  }) {
    final existingItemIndex = state.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingItemIndex != -1) {
      // Item already exists, increase quantity
      final updatedItem = state[existingItemIndex];
      state[existingItemIndex] = CartItem(
        product: updatedItem.product,
        selectedSize: updatedItem.selectedSize,
        selectedColor: updatedItem.selectedColor,
        quantity: updatedItem.quantity + 1,
      );
      state = [...state];
    } else {
      // Add new item
      state = [
        ...state,
        CartItem(
          product: product,
          selectedSize: size,
          selectedColor: color,
        ),
      ];
    }
  }

  void removeFromCart(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void removeItemByProductId(String productId, String size, String color) {
    state = state.where((item) => 
      !(item.product.id == productId && 
        item.selectedSize == size && 
        item.selectedColor == color)
    ).toList();
  }

  void incrementQuantity(String productId, String size, String color) {
    final index = state.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (index != -1) {
      final item = state[index];
      state[index] = CartItem(
        product: item.product,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor,
        quantity: item.quantity + 1,
      );
      state = [...state];
    }
  }

  void decrementQuantity(String productId, String size, String color) {
    final index = state.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (index != -1) {
      final item = state[index];
      if (item.quantity > 1) {
        state[index] = CartItem(
          product: item.product,
          selectedSize: item.selectedSize,
          selectedColor: item.selectedColor,
          quantity: item.quantity - 1,
        );
        state = [...state];
      } else {
        // Remove item if quantity becomes 0
        removeFromCart(index);
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double getTotalPrice() {
    return state.fold(0.0, (total, item) => total + item.totalPrice);
  }
}
