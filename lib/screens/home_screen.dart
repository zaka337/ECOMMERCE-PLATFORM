import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
// Ensure these imports point to your actual files
import 'product_detail_screen.dart'; 
import 'cart_screen.dart'; 

class HomeScreen extends ConsumerStatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // --- CLASSICAL THEME COLORS ---
  static const bgParchment = Color(0xFFF9F5EB); 
  static const bgCard = Color(0xFFFDFBF7);      
  static const textInk = Color(0xFF2C221C);     
  static const accentGold = Color(0xFFC5A059);  
  static const accentBurgundy = Color(0xFF7B1E1E); 
  static const frameBorder = Color(0xFFD4C5A5); 

  // --- TYPOGRAPHY ---
  static const serifStyle = TextStyle(fontFamily: 'Times New Roman', package: null);

  @override
  void initState() {
    super.initState();
    // Fetch products when screen loads
    Future.microtask(() => ref.read(productsProvider.notifier).fetchProducts());
  }

  // --- DIALOG: CREATE / EDIT PRODUCT ---
  void _showProductDialog(BuildContext context, {Product? existingProduct}) {
    final isEditing = existingProduct != null;
    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final priceController = TextEditingController(text: existingProduct?.price.toString() ?? '');
    final descController = TextEditingController(text: existingProduct?.description ?? '');
    final imageController = TextEditingController(text: existingProduct?.imageUrl ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: bgParchment,
          shape: BeveledRectangleBorder(
            side: const BorderSide(color: accentGold, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
          title: Column(
            children: [
              Text(
                isEditing ? 'AMEND LEDGER' : 'NEW ACQUISITION',
                style: serifStyle.copyWith(
                  color: accentBurgundy,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Divider(color: accentGold, thickness: 1, indent: 40, endIndent: 40),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVintageTextField(nameController, 'Artifact Name'),
                const SizedBox(height: 12),
                _buildVintageTextField(priceController, 'Value (Gold Coins)', isNumber: true),
                const SizedBox(height: 12),
                _buildVintageTextField(descController, 'Description / History'),
                const SizedBox(height: 12),
                _buildVintageTextField(imageController, 'Visual Reference (URL)'),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            if (!isLoading)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('DISCARD', style: serifStyle.copyWith(color: textInk)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBurgundy,
                foregroundColor: bgParchment,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: isLoading ? null : () async {
                // Validation with user feedback
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter an artifact name', style: serifStyle),
                      backgroundColor: accentBurgundy,
                    ),
                  );
                  return;
                }

                if (priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a value', style: serifStyle),
                      backgroundColor: accentBurgundy,
                    ),
                  );
                  return;
                }

                final priceValue = double.tryParse(priceController.text.trim());
                if (priceValue == null || priceValue <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid price', style: serifStyle),
                      backgroundColor: accentBurgundy,
                    ),
                  );
                  return;
                }

                setDialogState(() {
                  isLoading = true;
                });

                try {
                  final product = Product(
                    id: existingProduct?.id ?? '', // ID handled by provider for new items
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: priceValue,
                    imageUrl: imageController.text.trim(),
                  );

                  if (isEditing) {
                    await ref.read(productsProvider.notifier).updateProduct(product.id, product);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Record updated successfully', style: serifStyle),
                          backgroundColor: accentGold,
                        ),
                      );
                    }
                  } else {
                    await ref.read(productsProvider.notifier).addProduct(product);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('New entry recorded successfully', style: serifStyle),
                          backgroundColor: accentGold,
                        ),
                      );
                    }
                  }

                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                  }
                } catch (e) {
                  setDialogState(() {
                    isLoading = false;
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error: ${e.toString().replaceAll('Exception: ', '')}',
                          style: serifStyle,
                        ),
                        backgroundColor: accentBurgundy,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(bgParchment),
                      ),
                    )
                  : Text(
                      isEditing ? 'UPDATE RECORD' : 'RECORD ENTRY',
                      style: serifStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: VINTAGE INPUT ---
  Widget _buildVintageTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: serifStyle.copyWith(color: textInk),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: serifStyle.copyWith(color: textInk.withOpacity(0.6)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: frameBorder)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accentBurgundy)),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        isDense: true,
      ),
    );
  }

  // --- DELETE CONFIRMATION ---
  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgParchment,
        title: Text('Dispose Artifact?', style: serifStyle.copyWith(color: textInk)),
        content: Text('This action acts as an expungement from the archives.', style: serifStyle.copyWith(color: textInk)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('KEEP', style: serifStyle.copyWith(color: textInk)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(productsProvider.notifier).deleteProduct(productId);
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Artifact expunged from archives', style: serifStyle),
                      backgroundColor: accentGold,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${e.toString().replaceAll('Exception: ', '')}',
                        style: serifStyle,
                      ),
                      backgroundColor: accentBurgundy,
                    ),
                  );
                }
              }
            },
            child: Text('EXPUNGE', style: serifStyle.copyWith(color: accentBurgundy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: bgParchment,
      
      // --- APP BAR ---
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
            Container(height: 1, width: 60, color: accentGold),
            Container(margin: const EdgeInsets.only(top: 2), height: 1, width: 40, color: accentGold),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: textInk),
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
          ),
        ],
      ),

      // --- FLOATING ACTION BUTTON (NEW FEATURE) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context),
        backgroundColor: accentBurgundy,
        foregroundColor: bgParchment,
        // FIXED: Using standard 'Icons.edit' because 'Icons.edit_quill' is missing
        icon: const Icon(Icons.edit), 
        label: Text("NEW ENTRY", style: serifStyle.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GREETING ---
            Center(
              child: Text(
                'Est. 2024 • Greetings, ${widget.username}',
                style: serifStyle.copyWith(
                  color: textInk.withOpacity(0.6),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- HERO BANNER ---
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEBE3D5),
                border: Border.all(color: accentGold, width: 1),
                borderRadius: BorderRadius.circular(2),
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
                  Positioned(top: 8, left: 8, child: _CornerOrnament(color: accentGold)),
                  Positioned(top: 8, right: 8, child: RotatedBox(quarterTurns: 1, child: _CornerOrnament(color: accentGold))),
                  Positioned(bottom: 8, left: 8, child: RotatedBox(quarterTurns: 3, child: _CornerOrnament(color: accentGold))),
                  Positioned(bottom: 8, right: 8, child: RotatedBox(quarterTurns: 2, child: _CornerOrnament(color: accentGold))),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                                  fontSize: 10,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Grand Opening\nSale Event',
                                style: serifStyle.copyWith(
                                  fontSize: 20,
                                  color: textInk,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(border: Border.all(color: textInk)),
                                child: Text(
                                  "VIEW COLLECTION",
                                  style: serifStyle.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        // Placeholder Icon
                        Container(
                          width: 80,
                          height: 90,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.diamond_outlined, size: 40, color: Colors.grey),
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
              child: products.isEmpty 
              ? Center(child: Text("The archives are empty...", style: serifStyle.copyWith(color: textInk.withOpacity(0.5))))
              : GridView.builder(
                padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.60,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))
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
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(Icons.broken_image, color: frameBorder),
                                ),
                              ),
                            ),
                          ),
                          // Frame Details
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    "No. ${product.id.substring(0, product.id.length > 4 ? 4 : product.id.length)}",
                                    style: serifStyle.copyWith(
                                      fontSize: 10,
                                      color: textInk.withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: serifStyle.copyWith(
                                      color: accentBurgundy,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  // --- EDIT / DELETE ACTIONS ---
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18, color: textInk),
                                        onPressed: () => _showProductDialog(context, existingProduct: product),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Container(width: 1, height: 12, color: frameBorder),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: accentBurgundy),
                                        onPressed: () => _confirmDelete(context, product.id),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
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
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    canvas.drawPath(path, paint);
    canvas.drawCircle(const Offset(4, 4), 1, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}