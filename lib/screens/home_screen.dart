import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends ConsumerWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    // --- CLASSICAL THEME COLORS ---
    const bgParchment = Color(0xFFF9F5EB); // Light cream paper
    const bgCard = Color(0xFFFDFBF7);      // Slightly lighter for cards
    const textInk = Color(0xFF2C221C);     // Dark sepia/brown ink
    const accentGold = Color(0xFFC5A059);  // Muted antique gold
    const accentBurgundy = Color(0xFF7B1E1E); // Deep royal red
    const frameBorder = Color(0xFFD4C5A5); // Beige frame border

    // --- TYPOGRAPHY STYLES ---
    const serifStyle = TextStyle(fontFamily: 'Times New Roman', package: null);

    return Scaffold(
      backgroundColor: bgParchment,
      
      // --- APP BAR: CLASSIC HEADER ---
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgParchment,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textInk),
          onPressed: () {},
        ),
        title: Column(
          children: [
            Text(
              'THE EMPORIUM',
              style: serifStyle.copyWith(
                color: textInk,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 4),
            // Decorative Underline
            Container(
              height: 1,
              width: 60,
              color: accentGold,
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 1,
              width: 40,
              color: accentGold,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: textInk),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
                Positioned(
                  right: 4,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentBurgundy,
                      shape: BoxShape.circle,
                      border: Border.all(color: bgParchment, width: 1.5),
                    ),
                    child: const Text(
                      '3', // Example count
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- GREETING ---
            Center(
              child: Text(
                'Est. 2024 • Greetings, $username',
                style: serifStyle.copyWith(
                  color: textInk.withOpacity(0.6),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- HERO BANNER: THE SCROLL ---
            Container(
              height: 140, // Reduced height from 180 to 140
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEBE3D5), // Darker parchment
                border: Border.all(color: accentGold, width: 1),
                borderRadius: BorderRadius.circular(2), // Sharp corners look more classic
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Corner Ornaments (Simulated with borders)
                  Positioned(top: 8, left: 8, child: _CornerOrnament(color: accentGold)),
                  Positioned(top: 8, right: 8, child: RotatedBox(quarterTurns: 1, child: _CornerOrnament(color: accentGold))),
                  Positioned(bottom: 8, left: 8, child: RotatedBox(quarterTurns: 3, child: _CornerOrnament(color: accentGold))),
                  Positioned(bottom: 8, right: 8, child: RotatedBox(quarterTurns: 2, child: _CornerOrnament(color: accentGold))),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Reduced padding
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ROYAL SELECTION',
                                style: serifStyle.copyWith(
                                  color: accentBurgundy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10, // Reduced font size
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Grand Opening\nSale Event',
                                style: serifStyle.copyWith(
                                  fontSize: 20, // Reduced font size
                                  color: textInk,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: textInk),
                                ),
                                child: Text(
                                  "VIEW COLLECTION",
                                  style: serifStyle.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        // Vintage Image Placeholder
                        Container(
                          width: 80, // Reduced width
                          height: 90, // Reduced height
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                            ],
                            image: const DecorationImage(
                              image: AssetImage('assets/images/shoe.png'), // Keeping your asset
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- PRODUCT GRID ---
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.65, // Taller for that portrait frame look
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgCard,
                        border: Border.all(color: frameBorder, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.05),
                            offset: const Offset(3, 3),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Frame Image
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: accentGold.withOpacity(0.3)),
                                color: Colors.white,
                              ),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Center(
                                  child: Icon(Icons.broken_image, color: frameBorder),
                                ),
                              ),
                            ),
                          ),
                          // Frame Details
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    product.name.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: serifStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: textInk,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "No. ${index + 1042}", // Fake catalog number
                                    style: serifStyle.copyWith(
                                      fontSize: 10,
                                      color: textInk.withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: serifStyle.copyWith(
                                      color: accentBurgundy,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // "Acquire" Text Button (instead of cart icon)
                                  Text(
                                    "~ Acquire ~",
                                    style: serifStyle.copyWith(
                                      fontSize: 10,
                                      color: textInk,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER: CORNER ORNAMENT ---
class _CornerOrnament extends StatelessWidget {
  final Color color;
  const _CornerOrnament({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _OrnamentPainter(color: color),
      ),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  final Color color;
  _OrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    // Simple L-shape with a curve for decoration
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    canvas.drawPath(path, paint);

    // Add a dot
    canvas.drawCircle(const Offset(4, 4), 1, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}