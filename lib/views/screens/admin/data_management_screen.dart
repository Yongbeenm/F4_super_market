import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/sample_data.dart';

/// Data Management Screen - Clean duplicates and upload fresh data
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;
  String _statusMessage = '';

  // Fresh categories with proper images
  final List<Map<String, dynamic>> _freshCategories = [
    {
      'name': 'Fruits & Vegetables',
      'imageUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800',
      'displayOrder': 1,
    },
    {
      'name': 'Dairy & Eggs',
      'imageUrl': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=800',
      'displayOrder': 2,
    },
    {
      'name': 'Meat & Seafood',
      'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=800',
      'displayOrder': 3,
    },
    {
      'name': 'Bakery & Bread',
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
      'displayOrder': 4,
    },
    {
      'name': 'Beverages',
      'imageUrl': 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?w=800',
      'displayOrder': 5,
    },
    {
      'name': 'Snacks & Sweets',
      'imageUrl': 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=800',
      'displayOrder': 6,
    },
    {
      'name': 'Frozen Foods',
      'imageUrl': 'https://images.unsplash.com/photo-1476887334197-56adbf254e1a?w=800',
      'displayOrder': 7,
    },
    {
      'name': 'Pantry & Canned',
      'imageUrl': 'https://images.unsplash.com/photo-1556910110-a5a63dfd393c?w=800',
      'displayOrder': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5),
      appBar: AppBar(
        title: const Text('Data Management'),
        backgroundColor: const Color(0xFF0D5C3D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

            // Quick Setup Button (NEW!)
            _buildActionButton(
              '🚀 Quick Setup (All Data)',
              'Upload categories + products automatically',
              Icons.rocket_launch,
              Colors.green,
              _isProcessing ? null : _quickSetup,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Clean Duplicates Button
            _buildActionButton(
              'Clean Duplicate Products',
              'Remove duplicate products from database',
              Icons.cleaning_services,
              Colors.orange,
              _isProcessing ? null : _cleanDuplicateProducts,
            ),

            const SizedBox(height: 12),
            _buildActionButton(
              'Clean Duplicate Categories',
              'Remove duplicate categories from database',
              Icons.category,
              Colors.purple,
              _isProcessing ? null : _cleanDuplicateCategories,
            ),

            const SizedBox(height: 12),
            _buildActionButton(
              'Upload Fresh Categories',
              'Upload new categories with proper images',
              Icons.upload,
              Colors.blue,
              _isProcessing ? null : _uploadFreshCategories,
            ),

            const SizedBox(height: 12),
            _buildActionButton(
              'Upload Fresh Products',
              'Upload diverse products with images',
              Icons.inventory,
              Colors.green,
              _isProcessing ? null : _uploadFreshProducts,
            ),

            const SizedBox(height: 12),
            _buildActionButton(
              'Clear All Data',
              'Remove all products and categories',
              Icons.delete_forever,
              Colors.red,
              _isProcessing ? null : _clearAllData,
            ),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D5C3D),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5C3D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cleanDuplicateProducts() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Cleaning duplicate products...';
    });

    try {
      final productsSnapshot = await _firestore.collection('products').get();
      final Map<String, List<String>> productsByName = {};

      // Group products by name
      for (var doc in productsSnapshot.docs) {
        final name = doc.data()['name'] as String?;
        if (name != null) {
          if (!productsByName.containsKey(name)) {
            productsByName[name] = [];
          }
          productsByName[name]!.add(doc.id);
        }
      }

      // Delete duplicates (keep first, delete rest)
      int deletedCount = 0;
      for (var entry in productsByName.entries) {
        if (entry.value.length > 1) {
          // Keep first, delete rest
          for (int i = 1; i < entry.value.length; i++) {
            await _firestore.collection('products').doc(entry.value[i]).delete();
            deletedCount++;
          }
        }
      }

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Cleaned $deletedCount duplicate products!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _cleanDuplicateCategories() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Cleaning duplicate categories...';
    });

    try {
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final Map<String, List<String>> categoriesByName = {};

      // Group categories by name
      for (var doc in categoriesSnapshot.docs) {
        final name = doc.data()['name'] as String?;
        if (name != null) {
          if (!categoriesByName.containsKey(name)) {
            categoriesByName[name] = [];
          }
          categoriesByName[name]!.add(doc.id);
        }
      }

      // Delete duplicates (keep first, delete rest)
      int deletedCount = 0;
      for (var entry in categoriesByName.entries) {
        if (entry.value.length > 1) {
          // Keep first, delete rest
          for (int i = 1; i < entry.value.length; i++) {
            await _firestore.collection('categories').doc(entry.value[i]).delete();
            deletedCount++;
          }
        }
      }

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Cleaned $deletedCount duplicate categories!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });
    }
  }


  Future<void> _uploadFreshCategories() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Uploading fresh categories...';
    });

    try {
      // First, clean existing categories
      final existingCategories = await _firestore.collection('categories').get();
      for (var doc in existingCategories.docs) {
        await doc.reference.delete();
      }

      // Upload fresh categories
      for (var category in _freshCategories) {
        await _firestore.collection('categories').add({
          ...category,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Uploaded ${_freshCategories.length} fresh categories with images!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _uploadFreshProducts() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Uploading fresh products...';
    });

    try {
      // Get category IDs
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final Map<String, String> categoryMap = {};
      
      for (var doc in categoriesSnapshot.docs) {
        final name = doc.data()['name'] as String;
        categoryMap[name] = doc.id;
      }

      // Fresh products with proper images
      final freshProducts = _getFreshProducts(categoryMap);

      // Upload products
      for (var product in freshProducts) {
        await _firestore.collection('products').add({
          ...product,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Uploaded ${freshProducts.length} fresh products!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _clearAllData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all products and categories. This action cannot be undone!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Clearing all data...';
    });

    try {
      // Delete all products
      final products = await _firestore.collection('products').get();
      for (var doc in products.docs) {
        await doc.reference.delete();
      }

      // Delete all categories
      final categories = await _firestore.collection('categories').get();
      for (var doc in categories.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _isProcessing = false;
        _statusMessage = 'All data cleared successfully!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });
    }
  }


  Future<void> _quickSetup() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Setting up your store... This may take a minute.';
    });

    try {
      // Upload all sample data (categories + products)
      final result = await SampleData.uploadAll();

      final categoriesCount = result['categories'] ?? 0;
      final productsCount = result['products'] ?? 0;
      
      final message = '✅ Setup complete!\n\n'
          '📁 Categories: $categoriesCount\n'
          '📦 Products: $productsCount\n\n'
          'Your store is ready!';

      setState(() {
        _isProcessing = false;
        _statusMessage = message;
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('✅ Success!'),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C3D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  List<Map<String, dynamic>> _getFreshProducts(Map<String, String> categoryMap) {
    return [
      // Fruits & Vegetables
      {
        'name': 'Fresh Red Apples',
        'description': 'Crisp and sweet red apples, perfect for snacking or baking. Rich in fiber and vitamin C.',
        'price': 2.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
      {
        'name': 'Organic Bananas',
        'description': 'Ripe yellow bananas, great source of potassium. Perfect for smoothies and breakfast.',
        'price': 1.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800'],
        'stock': 200,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Strawberries',
        'description': 'Sweet and juicy strawberries, freshly picked. Perfect for desserts.',
        'price': 4.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800'],
        'stock': 80,
        'isAvailable': true,
      },
      {
        'name': 'Navel Oranges',
        'description': 'Juicy navel oranges, high in vitamin C. Great for fresh juice.',
        'price': 3.49,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1547514701-42782101795e?w=800'],
        'stock': 120,
        'isAvailable': true,
      },
      {
        'name': 'Organic Blueberries',
        'description': 'Fresh organic blueberries, packed with antioxidants. Perfect for smoothies.',
        'price': 5.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=800'],
        'stock': 60,
        'isAvailable': true,
      },
      {
        'name': 'Seedless Watermelon',
        'description': 'Sweet and refreshing watermelon, perfect for summer. Seedless variety.',
        'price': 6.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1587049352846-4a222e784422?w=800'],
        'stock': 45,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Broccoli',
        'description': 'Green broccoli crowns, rich in vitamins. Great for stir-fry and steaming.',
        'price': 2.49,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=800'],
        'stock': 90,
        'isAvailable': true,
      },
      {
        'name': 'Organic Carrots',
        'description': 'Crunchy orange carrots, high in beta-carotene. Perfect for salads.',
        'price': 1.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
      {
        'name': 'Vine Tomatoes',
        'description': 'Ripe red tomatoes, vine-ripened for maximum flavor. Perfect for salads.',
        'price': 3.29,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=800'],
        'stock': 110,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Lettuce',
        'description': 'Crisp lettuce, perfect for salads and sandwiches. Organic variety.',
        'price': 2.29,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=800'],
        'stock': 75,
        'isAvailable': true,
      },
      {
        'name': 'Bell Peppers Mix',
        'description': 'Colorful bell peppers (red, yellow, green). Sweet and crunchy.',
        'price': 3.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=800'],
        'stock': 85,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Spinach',
        'description': 'Fresh baby spinach leaves, rich in iron. Perfect for salads and cooking.',
        'price': 2.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=800'],
        'stock': 95,
        'isAvailable': true,
      },

      // Dairy & Eggs
      {
        'name': 'Whole Milk (1 Gallon)',
        'description': 'Fresh whole milk, rich and creamy. Perfect for drinking and cooking.',
        'price': 4.99,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1550583724-b2692b25a968?w=800'],
        'stock': 200,
        'isAvailable': true,
      },
      {
        'name': 'Sharp Cheddar Cheese',
        'description': 'Aged cheddar cheese, rich flavor. Perfect for sandwiches and cooking.',
        'price': 5.99,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=800'],
        'stock': 120,
        'isAvailable': true,
      },
      {
        'name': 'Greek Yogurt',
        'description': 'Creamy Greek yogurt, high in protein. Perfect for breakfast.',
        'price': 3.99,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
      {
        'name': 'Unsalted Butter',
        'description': 'Fresh unsalted butter, made from cream. Perfect for baking.',
        'price': 4.49,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=800'],
        'stock': 100,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Eggs (Dozen)',
        'description': 'Farm fresh eggs, grade A large. Perfect for breakfast and baking.',
        'price': 3.49,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=800'],
        'stock': 180,
        'isAvailable': true,
      },
      {
        'name': 'Mozzarella Cheese',
        'description': 'Fresh mozzarella cheese, perfect for pizza and pasta.',
        'price': 4.99,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1618164436241-4473940d1f5c?w=800'],
        'stock': 90,
        'isAvailable': true,
      },


      // Meat & Seafood
      {
        'name': 'Chicken Breast',
        'description': 'Fresh boneless chicken breast, lean protein. Perfect for grilling.',
        'price': 8.99,
        'categoryId': categoryMap['Meat & Seafood'],
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=800'],
        'stock': 70,
        'isAvailable': true,
      },
      {
        'name': 'Atlantic Salmon Fillet',
        'description': 'Fresh Atlantic salmon, rich in omega-3. Perfect for grilling.',
        'price': 12.99,
        'categoryId': categoryMap['Meat & Seafood'],
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800'],
        'stock': 50,
        'isAvailable': true,
      },
      {
        'name': 'Ground Beef (80/20)',
        'description': 'Lean ground beef, 80/20 blend. Perfect for burgers and tacos.',
        'price': 7.99,
        'categoryId': categoryMap['Meat & Seafood'],
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=800'],
        'stock': 85,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Shrimp',
        'description': 'Large fresh shrimp, peeled and deveined. Perfect for pasta and stir-fry.',
        'price': 14.99,
        'categoryId': categoryMap['Meat & Seafood'],
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=800'],
        'stock': 60,
        'isAvailable': true,
      },
      {
        'name': 'Pork Chops',
        'description': 'Bone-in pork chops, tender and juicy. Perfect for grilling.',
        'price': 9.99,
        'categoryId': categoryMap['Meat & Seafood'],
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1602470520998-f4a52199a3d6?w=800'],
        'stock': 55,
        'isAvailable': true,
      },

      // Bakery & Bread
      {
        'name': 'Whole Wheat Bread',
        'description': 'Fresh baked whole wheat bread, soft and nutritious.',
        'price': 3.49,
        'categoryId': categoryMap['Bakery & Bread'],
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800'],
        'stock': 80,
        'isAvailable': true,
      },
      {
        'name': 'French Croissants',
        'description': 'Buttery French croissants, flaky and delicious. Pack of 6.',
        'price': 4.99,
        'categoryId': categoryMap['Bakery & Bread'],
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800'],
        'stock': 60,
        'isAvailable': true,
      },
      {
        'name': 'Plain Bagels',
        'description': 'Fresh plain bagels, chewy and delicious. Pack of 6.',
        'price': 3.99,
        'categoryId': categoryMap['Bakery & Bread'],
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1551106652-a5bcf4b29ab6?w=800'],
        'stock': 90,
        'isAvailable': true,
      },
      {
        'name': 'Sourdough Bread',
        'description': 'Artisan sourdough bread, crusty outside and soft inside.',
        'price': 5.49,
        'categoryId': categoryMap['Bakery & Bread'],
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800'],
        'stock': 50,
        'isAvailable': true,
      },
      {
        'name': 'Chocolate Muffins',
        'description': 'Fresh baked chocolate muffins, moist and delicious. Pack of 4.',
        'price': 4.49,
        'categoryId': categoryMap['Bakery & Bread'],
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=800'],
        'stock': 70,
        'isAvailable': true,
      },

      // Beverages
      {
        'name': 'Fresh Orange Juice',
        'description': 'Fresh squeezed orange juice, no added sugar. 100% pure.',
        'price': 4.99,
        'categoryId': categoryMap['Beverages'],
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=800'],
        'stock': 90,
        'isAvailable': true,
      },
      {
        'name': 'Sparkling Water',
        'description': 'Refreshing sparkling water, lemon flavored. Zero calories.',
        'price': 3.99,
        'categoryId': categoryMap['Beverages'],
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1523362628745-0c100150b504?w=800'],
        'stock': 130,
        'isAvailable': true,
      },
      {
        'name': 'Green Tea',
        'description': 'Premium green tea bags, organic. Rich in antioxidants. 20 bags.',
        'price': 5.49,
        'categoryId': categoryMap['Beverages'],
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=800'],
        'stock': 80,
        'isAvailable': true,
      },
      {
        'name': 'Coffee Beans',
        'description': 'Premium Arabica coffee beans, medium roast. 1 lb bag.',
        'price': 12.99,
        'categoryId': categoryMap['Beverages'],
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800'],
        'stock': 65,
        'isAvailable': true,
      },
      {
        'name': 'Almond Milk',
        'description': 'Unsweetened almond milk, dairy-free. Perfect for coffee and cereal.',
        'price': 4.49,
        'categoryId': categoryMap['Beverages'],
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1550583724-b2692b25a968?w=800'],
        'stock': 100,
        'isAvailable': true,
      },
      {
        'name': 'Apple Juice',
        'description': '100% pure apple juice, no added sugar. 64 oz bottle.',
        'price': 3.99,
        'categoryId': categoryMap['Beverages'],
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=800'],
        'stock': 110,
        'isAvailable': true,
      },


      // Snacks & Sweets
      {
        'name': 'Potato Chips',
        'description': 'Crispy potato chips, classic salted flavor. Family size bag.',
        'price': 2.99,
        'categoryId': categoryMap['Snacks & Sweets'],
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
      {
        'name': 'Mixed Nuts',
        'description': 'Premium mixed nuts, roasted and salted. Great source of protein.',
        'price': 6.99,
        'categoryId': categoryMap['Snacks & Sweets'],
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73?w=800'],
        'stock': 100,
        'isAvailable': true,
      },
      {
        'name': 'Dark Chocolate Bar',
        'description': 'Premium dark chocolate, 70% cocoa. Rich and smooth.',
        'price': 3.49,
        'categoryId': categoryMap['Snacks & Sweets'],
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1511381939415-e44015466834?w=800'],
        'stock': 120,
        'isAvailable': true,
      },
      {
        'name': 'Granola Bars',
        'description': 'Healthy granola bars, oats and honey. Pack of 12.',
        'price': 4.99,
        'categoryId': categoryMap['Snacks & Sweets'],
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1590080876876-5a8e0c8e0f8f?w=800'],
        'stock': 95,
        'isAvailable': true,
      },
      {
        'name': 'Cookies Assortment',
        'description': 'Assorted cookies, chocolate chip and oatmeal. Family pack.',
        'price': 5.49,
        'categoryId': categoryMap['Snacks & Sweets'],
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=800'],
        'stock': 85,
        'isAvailable': true,
      },
      {
        'name': 'Popcorn',
        'description': 'Microwave popcorn, butter flavor. Pack of 6 bags.',
        'price': 3.99,
        'categoryId': categoryMap['Snacks & Sweets'],
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=800'],
        'stock': 110,
        'isAvailable': true,
      },

      // Frozen Foods
      {
        'name': 'Pepperoni Pizza',
        'description': 'Delicious frozen pizza, pepperoni flavor. Ready in 15 minutes.',
        'price': 6.99,
        'categoryId': categoryMap['Frozen Foods'],
        'categoryName': 'Frozen Foods',
        'imageUrls': ['https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800'],
        'stock': 70,
        'isAvailable': true,
      },
      {
        'name': 'Vanilla Ice Cream',
        'description': 'Premium vanilla ice cream, creamy and delicious. 1 quart.',
        'price': 5.99,
        'categoryId': categoryMap['Frozen Foods'],
        'categoryName': 'Frozen Foods',
        'imageUrls': ['https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=800'],
        'stock': 95,
        'isAvailable': true,
      },
      {
        'name': 'Mixed Vegetables',
        'description': 'Frozen mixed vegetables, broccoli, carrots, and peas. Ready to cook.',
        'price': 3.99,
        'categoryId': categoryMap['Frozen Foods'],
        'categoryName': 'Frozen Foods',
        'imageUrls': ['https://images.unsplash.com/photo-1590301157890-4810ed352733?w=800'],
        'stock': 110,
        'isAvailable': true,
      },
      {
        'name': 'Chicken Nuggets',
        'description': 'Breaded chicken nuggets, crispy and delicious. Family size.',
        'price': 7.99,
        'categoryId': categoryMap['Frozen Foods'],
        'categoryName': 'Frozen Foods',
        'imageUrls': ['https://images.unsplash.com/photo-1562967914-608f82629710?w=800'],
        'stock': 80,
        'isAvailable': true,
      },
      {
        'name': 'French Fries',
        'description': 'Crispy frozen french fries, perfect side dish. 2 lb bag.',
        'price': 4.49,
        'categoryId': categoryMap['Frozen Foods'],
        'categoryName': 'Frozen Foods',
        'imageUrls': ['https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=800'],
        'stock': 100,
        'isAvailable': true,
      },

      // Pantry & Canned
      {
        'name': 'Pasta (Spaghetti)',
        'description': 'Italian spaghetti pasta, perfect for any sauce. 1 lb box.',
        'price': 2.49,
        'categoryId': categoryMap['Pantry & Canned'],
        'categoryName': 'Pantry & Canned',
        'imageUrls': ['https://images.unsplash.com/photo-1551462147-37e8e0f44a1d?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
      {
        'name': 'Tomato Sauce',
        'description': 'Classic tomato sauce, perfect for pasta. 24 oz jar.',
        'price': 3.49,
        'categoryId': categoryMap['Pantry & Canned'],
        'categoryName': 'Pantry & Canned',
        'imageUrls': ['https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=800'],
        'stock': 120,
        'isAvailable': true,
      },
      {
        'name': 'White Rice',
        'description': 'Long grain white rice, perfect for any meal. 5 lb bag.',
        'price': 6.99,
        'categoryId': categoryMap['Pantry & Canned'],
        'categoryName': 'Pantry & Canned',
        'imageUrls': ['https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800'],
        'stock': 90,
        'isAvailable': true,
      },
      {
        'name': 'Canned Tuna',
        'description': 'Chunk light tuna in water, high in protein. Pack of 4 cans.',
        'price': 5.99,
        'categoryId': categoryMap['Pantry & Canned'],
        'categoryName': 'Pantry & Canned',
        'imageUrls': ['https://images.unsplash.com/photo-1520961880-4f2e0d3a7e3f?w=800'],
        'stock': 110,
        'isAvailable': true,
      },
      {
        'name': 'Olive Oil',
        'description': 'Extra virgin olive oil, cold pressed. Perfect for cooking. 500ml.',
        'price': 8.99,
        'categoryId': categoryMap['Pantry & Canned'],
        'categoryName': 'Pantry & Canned',
        'imageUrls': ['https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=800'],
        'stock': 75,
        'isAvailable': true,
      },
      {
        'name': 'Peanut Butter',
        'description': 'Creamy peanut butter, no added sugar. Perfect for sandwiches.',
        'price': 4.99,
        'categoryId': categoryMap['Pantry & Canned'],
        'categoryName': 'Pantry & Canned',
        'imageUrls': ['https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=800'],
        'stock': 95,
        'isAvailable': true,
      },
    ];
  }
}
