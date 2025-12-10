import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  // --- STATIC DATA FOR DISPLAY (Since DB doesn't have these fields yet) ---
  final List<String> _availableSizes = ['7', '8', '9', '10', '11', '12'];
  final List<String> _availableColors = ['Charcoal', 'Navy', 'Burgundy', 'Camel'];

  late String selectedSize;
  late String selectedColor;

  @override
  void initState() {
    super.initState();
    // Default to the first available option
    selectedSize = _availableSizes.first;
    selectedColor = _availableColors.first;
  }

  @override
  Widget build(BuildContext context) {
    // --- CLASSICAL THEME PALETTE ---
    const bgParchment = Color(0xFFF9F5EB);
    const textInk = Color(0xFF2C221C);
    const accentGold = Color(0xFFC5A059);
    const accentBurgundy = Color(0xFF7B1E1E);
    const frameBorder = Color(0xFFD4C5A5);

    // --- TYPOGRAPHY ---
    const serifStyle = TextStyle(fontFamily: 'Times New Roman', package: null);

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
        title: Text(
          'ARTIFACT DETAILS',
          style: serifStyle.copyWith(
            color: textInk,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
           IconButton(
            icon: const Icon(Icons.share_outlined, color: textInk),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // --- MUSEUM FRAME IMAGE ---
              Center(
                child: Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: frameBorder, width: 8), // Thick frame
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // The Image
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(4), // Inner matte
                          decoration: BoxDecoration(
                             border: Border.all(color: accentGold.withOpacity(0.3), width: 1),
                          ),
                          child: Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 80,
                              );
                            },
                          ),
                        ),
                      ),
                      // Corner Ornaments
                      Positioned(top: 4, left: 4, child: _CornerOrnament(color: accentGold)),
                      Positioned(top: 4, right: 4, child: RotatedBox(quarterTurns: 1, child: _CornerOrnament(color: accentGold))),
                      Positioned(bottom: 4, left: 4, child: RotatedBox(quarterTurns: 3, child: _CornerOrnament(color: accentGold))),
                      Positioned(bottom: 4, right: 4, child: RotatedBox(quarterTurns: 2, child: _CornerOrnament(color: accentGold))),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              // --- TITLE & RATING ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: serifStyle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textInk,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: accentGold),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: accentGold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '4.8', // Static rating since model doesn't have it yet
                          style: serifStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              
              // --- PRICE ---
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: serifStyle.copyWith(
                  fontSize: 26,
                  color: accentBurgundy,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 24),
              Divider(color: accentGold.withOpacity(0.5), thickness: 1),
              const SizedBox(height: 24),

              // --- SIZE SELECTOR (Historical Style) ---
              Text(
                'DIMENSIONS',
                style: serifStyle.copyWith(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5,
                  color: textInk.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _availableSizes.map((size) {
                  final isSelected = selectedSize == size;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSize = size),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? textInk : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? textInk : frameBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: serifStyle.copyWith(
                            color: isSelected ? Colors.white : textInk,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // --- COLOR SELECTOR ---
              Text(
                'FINISH',
                style: serifStyle.copyWith(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5,
                  color: textInk.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: _availableColors.map((color) {
                  final isSelected = selectedColor == color;
                  final colorValue = _getColorFromString(color);
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      padding: const EdgeInsets.all(2), // Gap for selection ring
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? accentBurgundy : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorValue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            )
                          ]
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // --- ACQUIRE BUTTON (Royal Seal Style) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBurgundy,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Sharp corners for formal look
                    ),
                    elevation: 5,
                    shadowColor: accentBurgundy.withOpacity(0.4),
                  ),
                  onPressed: () {
                    // NOTE: Ensure your CartProvider is updated to accept these arguments
                    ref.read(cartProvider.notifier).addToCart(
                          product: widget.product,
                          size: selectedSize,
                          color: selectedColor,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: textInk,
                        content: Text(
                          'Added to your collection.',
                          style: serifStyle.copyWith(color: bgParchment),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.approval, color: accentGold), // Seal icon
                      const SizedBox(width: 12),
                      Text(
                        'ACQUIRE ARTIFACT',
                        style: serifStyle.copyWith(
                          color: accentGold,
                          fontSize: 16,
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
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue': return Colors.blue[800]!;
      case 'black': return const Color(0xFF1A1A1A);
      case 'white': return const Color(0xFFF5F5F5);
      case 'gray':
      case 'grey': return Colors.grey;
      case 'navy': return const Color(0xFF001F3F);
      case 'red': 
      case 'burgundy': return const Color(0xFF8B0000);
      case 'charcoal': return const Color(0xFF36454F);
      case 'camel': return const Color(0xFFC19A6B);
      case 'green': return const Color(0xFF006400);
      default: return Colors.grey;
    }
  }
}

// --- REUSED ORNAMENT WIDGET ---
class _CornerOrnament extends StatelessWidget {
  final Color color;
  const _CornerOrnament({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
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
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(0, 0, size.width, 0); // Slight curve for elegance
    canvas.drawPath(path, paint);
    
    // Decorative dot
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(const Offset(6, 6), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}