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

  void clearCart() {
    state = [];
  }

  double getTotalPrice() {
    return state.fold(0, (total, item) => total + item.totalPrice);
  }
}
