import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class FashionCategoryScreen extends ConsumerStatefulWidget {
  final String title; // "MEN'S" or "WOMEN'S"
  final List<String> categories;

  const FashionCategoryScreen({
    Key? key,
    required this.title,
    required this.categories,
  }) : super(key: key);

  @override
  ConsumerState<FashionCategoryScreen> createState() => _FashionCategoryScreenState();
}

class _FashionCategoryScreenState extends ConsumerState<FashionCategoryScreen> {
  // --- THEME CONSTANTS ---
  static const colorBackground = Color(0xFFF5F5F7);
  static const colorDarkGreen = Color(0xFF1E3A34);
  static const colorBlack = Color(0xFF000000);
  
  // --- STATE ---
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories.first;
  }

  // --- TYPOGRAPHY ---
  static const modernStyle = TextStyle(
    fontFamily: 'Arial',
    color: colorBlack,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    // 1. Get ALL products
    final allProducts = ref.watch(productsProvider);
    
    // 2. Filter logic
    // Convert "MEN'S" to "Men" and "WOMEN'S" to "Women" for comparison
    final genderFilter = widget.title.toUpperCase().contains("MEN") && !widget.title.toUpperCase().contains("WO") 
        ? "Men" 
        : "Women";

    final filteredProducts = allProducts.where((prod) {
      // Check both Gender and Category
      return prod.gender == genderFilter && prod.category == selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorBlack),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: colorBlack),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: modernStyle.copyWith(
                    fontSize: 40, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.0
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "COLLECTION",
                      style: modernStyle.copyWith(
                        fontSize: 24, 
                        fontWeight: FontWeight.w300
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 2,
                      width: 50,
                      color: colorBlack,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- HORIZONTAL CATEGORY PILLS ---
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = widget.categories[index];
                final isSelected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? colorBlack : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorBlack),
                    ),
                    child: Text(
                      cat,
                      style: modernStyle.copyWith(
                        color: isSelected ? Colors.white : colorBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // --- PRODUCT GRID ---
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(child: Text("No items found in $selectedCategory", style: modernStyle))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      // Reusing the modern card design
                      return _buildModernProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- REUSED CARD DESIGN ---
  Widget _buildModernProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        height: 380, 
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: colorDarkGreen,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            // 1. Title
            Positioned(
              top: 25,
              left: 25,
              right: 80,
              child: Text(
                product.name.toUpperCase(),
                style: modernStyle.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 2. Image
            Positioned(
              top: 60,
              left: 50,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                ),
              ),
            ),

            // 3. Price
            Positioned(
              left: 20,
              bottom: 100,
              child: RotatedBox(
                quarterTurns: 3, 
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: modernStyle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            // 4. Details Button
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB), 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,5))
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_outward, size: 20, color: Colors.black),
                      const SizedBox(height: 2),
                      Text("Details", style: modernStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}