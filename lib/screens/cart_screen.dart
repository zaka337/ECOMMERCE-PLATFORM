import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- CLASSICAL THEME PALETTE (Matched to Product Detail) ---
    const bgParchment = Color(0xFFF9F5EB);
    const textInk = Color(0xFF2C221C);
    const accentGold = Color(0xFFC5A059);
    const accentBurgundy = Color(0xFF7B1E1E);
    const frameBorder = Color(0xFFD4C5A5);
    const paperWhite = Color(0xFFFDFBF7);

    // --- TYPOGRAPHY ---
    const serifStyle = TextStyle(fontFamily: 'Times New Roman', package: null);

    final cartItems = ref.watch(cartProvider);
    
    // FIX: Calculate total locally to ensure it works without a specific provider getter
    final totalAmount = cartItems.fold<double>(
      0, 
      (sum, item) => sum + (item.product.price * item.quantity)
    );

    return Scaffold(
      backgroundColor: bgParchment,
      appBar: AppBar(
        backgroundColor: bgParchment,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              "MERCHANT'S LEDGER",
              style: serifStyle.copyWith(
                color: textInk,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(height: 1, width: 60, color: accentGold),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: textInk),
            onPressed: () {
               // Optional: Clear cart logic
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- CART LIST ---
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_edu, size: 60, color: textInk.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          "Your ledger is empty.",
                          style: serifStyle.copyWith(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: textInk.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    separatorBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: accentGold.withOpacity(0.3)),
                    ),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: paperWhite,
                          border: Border.all(color: frameBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            // --- THUMBNAIL (Framed) ---
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                border: Border.all(color: accentGold.withOpacity(0.5)),
                                color: Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                                    ),
                                  ),
                                  // Tiny corner ornaments
                                  Positioned(top: 0, left: 0, child: _MicroOrnament(color: accentGold)),
                                  Positioned(bottom: 0, right: 0, child: _MicroOrnament(color: accentGold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // --- DETAILS ---
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: serifStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textInk,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.selectedSize}  •  ${item.selectedColor}',
                                    style: serifStyle.copyWith(
                                      fontSize: 12,
                                      color: textInk.withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: serifStyle.copyWith(
                                      fontSize: 16,
                                      color: accentBurgundy,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // --- QUANTITY ---
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                     // TODO: Implement incrementQuantity in your CartNotifier
                                     // ref.read(cartProvider.notifier).incrementQuantity(item.product.id);
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text('Increment logic required in provider'))
                                     );
                                  },
                                  child: Icon(Icons.keyboard_arrow_up, color: textInk),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: frameBorder),
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: serifStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                     // TODO: Implement decrementQuantity in your CartNotifier
                                     // ref.read(cartProvider.notifier).decrementQuantity(item.product.id);
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text('Decrement logic required in provider'))
                                     );
                                  },
                                  child: Icon(Icons.keyboard_arrow_down, color: textInk),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // --- FINAL RECKONING (Checkout) ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: paperWhite,
              border: Border(top: BorderSide(color: accentGold, width: 2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                )
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "FINAL RECKONING",
                        style: serifStyle.copyWith(
                          fontSize: 14,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          color: textInk.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: serifStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textInk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBurgundy,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // Checkout logic
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined, color: accentGold, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'SEAL THE COVENANT',
                            style: serifStyle.copyWith(
                              color: accentGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- MICRO ORNAMENT FOR THUMBNAILS ---
class _MicroOrnament extends StatelessWidget {
  final Color color;
  const _MicroOrnament({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      color: color,
    );
  }
}