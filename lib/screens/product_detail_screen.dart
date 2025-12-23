import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// For blur effects if needed
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  // --- STATE ---
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _colors = ['Green', 'Black', 'Blue', 'Camel'];

  late String selectedSize;
  late String selectedColor;

  @override
  void initState() {
    super.initState();
    selectedSize = 'XL';
    selectedColor = 'Green';
  }

  // --- THEME COLORS (Extracted from your image) ---
  static const Color colorTextWhite = Colors.white;
  static const Color colorTextDim = Color(0xFFB0B0B0); // Light grey for labels
  static const Color colorAccentGreen = Color(0xFF1E3A34); // Deep green for gradient
  static const Color colorBlack = Color(0xFF000000);
  static const Color colorDivider = Color(0xFF505050); // Dim line color

  // --- TYPOGRAPHY HELPERS ---
  TextStyle fontHeader(BuildContext context) => TextStyle(
    fontFamily: 'Arial',
    color: colorTextWhite,
    fontSize: MediaQuery.of(context).size.width * 0.08,
    fontWeight: FontWeight.w300,
    letterSpacing: 2.0,
  );

  TextStyle get fontLabel => const TextStyle(
    fontFamily: 'Arial',
    color: colorTextDim,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  TextStyle fontValue(BuildContext context) => TextStyle(
    fontFamily: 'Arial',
    color: colorTextWhite,
    fontSize: MediaQuery.of(context).size.width * 0.06,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: colorBlack,
      body: Stack(
        children: [
          // -------------------------------------------
          // 1. BACKGROUND IMAGE
          // -------------------------------------------
          Positioned.fill(
            child: Image.network(
              widget.product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: colorAccentGreen),
            ),
          ),

          // -------------------------------------------
          // 2. DARK GRADIENT OVERLAY
          // -------------------------------------------
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorBlack.withOpacity(0.8), // Dark at top for text
                    colorAccentGreen.withOpacity(0.3), // Clearer in middle
                    colorBlack.withOpacity(0.9), // Dark at bottom for text
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // -------------------------------------------
          // 3. TOP BAR (Back Arrow & Cart Pill)
          // -------------------------------------------
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: colorTextWhite),
                  onPressed: () => Navigator.pop(context),
                ),
                // Cart Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: Text(
                    "Cart ${cartItems.length}",
                    style: const TextStyle(color: colorTextWhite, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------
          // 4. "DETAILS" HEADER & INFO ROW
          // -------------------------------------------
          Positioned(
            top: 120, // Adjust based on your image preference
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: "DETAILS   HOODIE"
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("DETAILS", style: fontHeader(context)),
                    const SizedBox(width: 12),
                    Text(
                      "HOODIE", // Or widget.product.category
                      style: fontLabel.copyWith(fontSize: 14, letterSpacing: 2),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                const Divider(color: Colors.white54, thickness: 1),
                const SizedBox(height: 20),

                // INFO COLUMNS: Size | Color | Price
                Row(
                  children: [
                    // SIZE
                    _buildInfoColumn(
                      label: "Size", 
                      value: selectedSize, 
                      onTap: () => _showSelectionModal("Size", _sizes, (val) => setState(() => selectedSize = val))
                    ),
                    _buildVerticalDivider(),
                    
                    // COLOR
                    _buildInfoColumn(
                      label: "Color", 
                      value: selectedColor, 
                      onTap: () => _showSelectionModal("Color", _colors, (val) => setState(() => selectedColor = val))
                    ),
                    _buildVerticalDivider(),

                    // PRICE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Price", style: fontLabel),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text("\$${widget.product.price.toInt()}", style: fontValue(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // -------------------------------------------
          // 5. BOTTOM SECTION (Cloth Rate & Action Button)
          // -------------------------------------------
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // "Cloth rate" Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cloth rate", style: fontLabel.copyWith(fontSize: 16)),
                    const SizedBox(height: 0),
                    Text(
                      "85.2%", 
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: colorTextWhite,
                        fontSize: 60, // Huge font
                        fontWeight: FontWeight.w300, // Very thin
                        letterSpacing: -2.0, 
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),

                // White Circular Action Button
                GestureDetector(
                  onTap: () {
                    // Add to cart logic
                    ref.read(cartProvider.notifier).addToCart(
                      product: widget.product,
                      size: selectedSize,
                      color: selectedColor,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to Cart")),
                    );
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: colorTextWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_outward, // The specific diagonal arrow icon
                      color: colorBlack,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildInfoColumn({required String label, required String value, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: fontLabel),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: fontValue(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 35,
      width: 1,
      color: Colors.white24,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03,
      ),
    );
  }

  // --- MODAL FOR SELECTION (Since the design is clean, we pop up to select) ---
  void _showSelectionModal(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select $title", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: (title == "Size" ? selectedSize : selectedColor) == option,
                    onSelected: (bool selected) {
                      if (selected) {
                        onSelect(option);
                        Navigator.pop(ctx);
                      }
                    },
                    selectedColor: Colors.white,
                    backgroundColor: Colors.black,
                    labelStyle: TextStyle(
                      color: (title == "Size" ? selectedSize : selectedColor) == option ? Colors.black : Colors.white
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}