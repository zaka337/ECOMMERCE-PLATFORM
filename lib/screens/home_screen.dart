import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/store_provider.dart';
import '../models/product.dart';
// Ensure these imports point to your actual files
import 'settings_screen.dart';
import 'fashion_category_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'auth_screen.dart';
import 'store_registration_screen.dart';
import 'store_dashboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // --- MODERN THEME COLORS ---
  static const colorBackground = Color(0xFFF5F5F7); // Light Grey/White background
  static const colorDarkGreen = Color(0xFF1E3A34);  // The main card color
  static const colorBlack = Color(0xFF000000);
  static const colorWhite = Color(0xFFFFFFFF);

  // --- TYPOGRAPHY ---
  static const modernStyle = TextStyle(
    fontFamily: 'Arial', // Use your app's font
    color: colorBlack,
    letterSpacing: 0.5,
  );

  @override
  void initState() {
    super.initState();
    // We still fetch products to display them, but we don't edit them.
    Future.microtask(() {
      ref.read(productsProvider.notifier).fetchProducts();
      // Load user's store if they are a store owner
      ref.read(storeProvider.notifier).loadUserStore();
    });
  }

  // --- NAVIGATION MENU LOGIC ---
 void _handleMenuSelection(String value) {
    switch (value) {
      case 'Cart':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
        break;
      
      case 'My Store':
        final store = ref.read(storeProvider);
        if (store != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreDashboardScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreRegistrationScreen()));
        }
        break;
      
      case 'Create Store':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreRegistrationScreen()));
        break;
      
      case 'Men':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FashionCategoryScreen(
          title: "MEN'S",
          categories: ['Jackets', 'Shoes', 'Perfumes', 'Suits', 'Accessories'],
        )));
        break;
      
      case 'Women':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FashionCategoryScreen(
          title: "WOMEN'S",
          categories: ['Jewelry', 'Jackets', 'Western', 'Bags', 'Footwear'],
        )));
        break;
      
      case 'Settings':
        // Navigate to the new Settings Screen
        Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(username: widget.username)));
        break;
      
      case 'Logout':
        _confirmLogout();
        break;
    }
  }


  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen(initialIsLogin: true)),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: colorBackground,
      
      // --- APP BAR ---
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorBackground,
        automaticallyImplyLeading: false, 
        title: Text(
          'COTUR',
          style: modernStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: colorBlack,
          ),
        ),
        actions: [
          // Custom Menu Button
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorBlack, width: 1.5),
              ),
              child: const Icon(Icons.sort, color: colorBlack, size: 20),
            ),
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) {
              final store = ref.read(storeProvider);
              final menuItems = <String>['Cart'];
              
              // Add store-related menu item
              if (store != null) {
                menuItems.add('My Store');
              } else {
                menuItems.add('Create Store');
              }
              
              menuItems.addAll(['Men', 'Women', 'Settings', 'Logout']);
              
              return menuItems.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: modernStyle),
                );
              }).toList();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      // NO FloatingActionButton (CRUD Removed)

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          
          // --- HEADER SECTION (Fashion Beyond Reality) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FASHION",
                  style: modernStyle.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.09, // Responsive
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: colorBlack,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_outward, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        "BEYOND",
                        style: modernStyle.copyWith(
                          fontSize: MediaQuery.of(context).size.width * 0.09, // Responsive
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  "REALITY",
                  style: modernStyle.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.09, // Responsive
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- PRODUCT LIST ---
          Expanded(
            child: products.isEmpty 
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 60, color: colorBlack.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        "No products available",
                        style: modernStyle.copyWith(
                          color: colorBlack.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).padding.bottom + 40,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildModernProductCard(product);
                },
              ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: THE MODERN CARD (Display Only) ---
  Widget _buildModernProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        // Navigate to Product Detail
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5, // Responsive height
        constraints: const BoxConstraints(minHeight: 300, maxHeight: 450),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: colorDarkGreen,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            // 1. PRODUCT TITLE (Top Left)
            Positioned(
              top: 20,
              left: 20,
              right: 70,
              child: Text(
                product.name.toUpperCase(),
                style: modernStyle.copyWith(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 2. MAIN IMAGE (Centered/Bottom-ish)
            Positioned(
              top: 60,
              left: 50, // Leave space for rotated price
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported, color: Colors.white24, size: 50)),
                ),
              ),
            ),

            // 3. ROTATED PRICE (Left Side)
            Positioned(
              left: 15,
              bottom: 80,
              child: RotatedBox(
                quarterTurns: 3, // Rotate 270 degrees
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: modernStyle.copyWith(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // 4. "DETAILS" CIRCLE BUTTON (Bottom Center overlay)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEBEB), // Slightly off-white
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,5))
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_outward, size: MediaQuery.of(context).size.width * 0.05, color: Colors.black),
                      const SizedBox(height: 2),
                      Text("Details", style: modernStyle.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            // 5. DECORATIVE TAG (Optional "Yellow" tag from image)
            Positioned(
              top: 70,
              left: 50,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Collection",
                  style: modernStyle.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}