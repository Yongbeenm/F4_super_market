import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/sample_data.dart';
import 'product_list_screen.dart';

/// Home Screen - With Firebase Integration
/// Shows banner, "Shop by Category" section with product grid
/// Loads categories and products from Firestore
class HomeScreenWithFirebase extends StatefulWidget {
  const HomeScreenWithFirebase({super.key});

  @override
  State<HomeScreenWithFirebase> createState() => _HomeScreenWithFirebaseState();
}

class _HomeScreenWithFirebaseState extends State<HomeScreenWithFirebase> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Try to load from Firestore
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('displayOrder')
          .get();

      if (snapshot.docs.isEmpty) {
        // No data in Firestore, use sample data
        setState(() {
          _categories = SampleData.categories;
          _isLoading = false;
        });
      } else {
        // Use Firestore data
        setState(() {
          _categories = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Error loading from Firestore, fallback to sample data
      print('Error loading categories: $e');
      setState(() {
        _categories = SampleData.categories;
        _error = 'Using offline data';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadProductsByCategory(
      String categoryId) async {
    try {
      // Try to load from Firestore
      final snapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isAvailable', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        // No data in Firestore, use sample data
        return SampleData.products
            .where((p) => p['categoryId'] == categoryId)
            .toList();
      } else {
        // Use Firestore data
        return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      // Error loading from Firestore, fallback to sample data
      print('Error loading products: $e');
      return SampleData.products
          .where((p) => p['categoryId'] == categoryId)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5), // Mint green
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Greeting
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hi, Hello',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5C3D),
                        ),
                      ),
                      Text(
                        'What are you looking for today?',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF0D5C3D).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Cart Icon with Badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Color(0xFF0D5C3D),
                          size: 28,
                        ),
                        onPressed: () {
                          // Navigate to cart
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: const Text(
                            '0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Error banner (if using offline data)
            if (_error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D5C3D),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCategories,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Banner Card
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0D5C3D),
                                      Color(0xFF1A8A5C),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Decorative circles
                                    Positioned(
                                      right: -20,
                                      top: -20,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -30,
                                      bottom: -30,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "This week's fresh picks!",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Get the freshest fruits and vegetables',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Navigate to fruits category
                                              final products =
                                                  await _loadProductsByCategory(
                                                      'cat_fruits');
                                              if (mounted) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductListScreen(
                                                      categoryId: 'cat_fruits',
                                                      categoryName: 'Fruits',
                                                      products: products,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor:
                                                  const Color(0xFF0D5C3D),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text(
                                              'Shop Now',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Shop by Category Section
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Shop by Category',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D5C3D),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Category Grid from Firebase
                            _categories.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                        'No categories available.\nPlease upload sample data.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF0D5C3D),
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                      ),
                                      itemCount: _categories.length,
                                      itemBuilder: (context, index) {
                                        final category = _categories[index];
                                        return _buildCategoryCard(
                                          category['name'] ?? 'Category',
                                          category['categoryId'] ?? '',
                                          _getCategoryEmoji(
                                              category['name'] ?? ''),
                                          _getCategoryColor(
                                              category['name'] ?? ''),
                                        );
                                      },
                                    ),
                                  ),

                            const SizedBox(height: 24),
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

  Widget _buildCategoryCard(
      String name, String categoryId, String emoji, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Load products for this category
            final products = await _loadProductsByCategory(categoryId);

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(
                    categoryId: categoryId,
                    categoryName: name,
                    products: products,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D5C3D),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryEmoji(String name) {
    final emojiMap = {
      'Fruits': '🍎',
      'Vegetables': '🥕',
      'Dairy': '🥛',
      'Bakery': '🍞',
      'Meat & Seafood': '🥩',
      'Snacks': '🍿',
      'Beverages': '🥤',
      'Frozen Foods': '🧊',
    };
    return emojiMap[name] ?? '📦';
  }

  Color _getCategoryColor(String name) {
    final colorMap = {
      'Fruits': Colors.red,
      'Vegetables': Colors.orange,
      'Dairy': Colors.blue,
      'Bakery': Colors.brown,
      'Meat & Seafood': Colors.red.shade900,
      'Snacks': Colors.yellow,
      'Beverages': Colors.purple,
      'Frozen Foods': Colors.cyan,
    };
    return colorMap[name] ?? Colors.green;
  }
}
