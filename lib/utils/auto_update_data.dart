import 'package:cloud_firestore/cloud_firestore.dart';

/// Auto Update Data Utility
/// This will clean duplicates and upload fresh data automatically
class AutoUpdateData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run all updates automatically
  Future<Map<String, dynamic>> runAllUpdates() async {
    final results = <String, dynamic>{};

    try {
      // Step 1: Clean duplicate products
      results['duplicateProducts'] = await cleanDuplicateProducts();
      
      // Step 2: Clean duplicate categories
      results['duplicateCategories'] = await cleanDuplicateCategories();
      
      // Step 3: Upload fresh categories
      results['categoriesUploaded'] = await uploadFreshCategories();
      
      // Step 4: Upload fresh products
      results['productsUploaded'] = await uploadFreshProducts();
      
      results['success'] = true;
      results['message'] = 'All updates completed successfully!';
    } catch (e) {
      results['success'] = false;
      results['message'] = 'Error: $e';
    }

    return results;
  }

  Future<int> cleanDuplicateProducts() async {
    final productsSnapshot = await _firestore.collection('products').get();
    final Map<String, List<String>> productsByName = {};

    for (var doc in productsSnapshot.docs) {
      final name = doc.data()['name'] as String?;
      if (name != null) {
        if (!productsByName.containsKey(name)) {
          productsByName[name] = [];
        }
        productsByName[name]!.add(doc.id);
      }
    }

    int deletedCount = 0;
    for (var entry in productsByName.entries) {
      if (entry.value.length > 1) {
        for (int i = 1; i < entry.value.length; i++) {
          await _firestore.collection('products').doc(entry.value[i]).delete();
          deletedCount++;
        }
      }
    }

    return deletedCount;
  }

  Future<int> cleanDuplicateCategories() async {
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final Map<String, List<String>> categoriesByName = {};

    for (var doc in categoriesSnapshot.docs) {
      final name = doc.data()['name'] as String?;
      if (name != null) {
        if (!categoriesByName.containsKey(name)) {
          categoriesByName[name] = [];
        }
        categoriesByName[name]!.add(doc.id);
      }
    }

    int deletedCount = 0;
    for (var entry in categoriesByName.entries) {
      if (entry.value.length > 1) {
        for (int i = 1; i < entry.value.length; i++) {
          await _firestore.collection('categories').doc(entry.value[i]).delete();
          deletedCount++;
        }
      }
    }

    return deletedCount;
  }

  Future<int> uploadFreshCategories() async {
    // Delete existing categories
    final existingCategories = await _firestore.collection('categories').get();
    for (var doc in existingCategories.docs) {
      await doc.reference.delete();
    }

    final categories = [
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

    for (var category in categories) {
      await _firestore.collection('categories').add({
        ...category,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return categories.length;
  }

  Future<int> uploadFreshProducts() async {
    // Get category IDs first
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final Map<String, String> categoryMap = {};
    
    for (var doc in categoriesSnapshot.docs) {
      final name = doc.data()['name'] as String;
      categoryMap[name] = doc.id;
    }

    // Delete existing products
    final existingProducts = await _firestore.collection('products').get();
    for (var doc in existingProducts.docs) {
      await doc.reference.delete();
    }

    final products = _getProductsList(categoryMap);

    for (var product in products) {
      await _firestore.collection('products').add({
        ...product,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return products.length;
  }

  List<Map<String, dynamic>> _getProductsList(Map<String, String> categoryMap) {
    return [
      // Fruits & Vegetables
      {
        'name': 'Fresh Red Apples',
        'description': 'Crisp and sweet red apples, perfect for snacking or baking.',
        'price': 2.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
      {
        'name': 'Organic Bananas',
        'description': 'Ripe yellow bananas, great source of potassium.',
        'price': 1.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800'],
        'stock': 200,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Strawberries',
        'description': 'Sweet and juicy strawberries, freshly picked.',
        'price': 4.99,
        'categoryId': categoryMap['Fruits & Vegetables'],
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800'],
        'stock': 80,
        'isAvailable': true,
      },
      // Add more products as needed...
      // I'll add a representative sample from each category
      
      // Dairy & Eggs
      {
        'name': 'Whole Milk (1 Gallon)',
        'description': 'Fresh whole milk, rich and creamy.',
        'price': 4.99,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1550583724-b2692b25a968?w=800'],
        'stock': 200,
        'isAvailable': true,
      },
      {
        'name': 'Fresh Eggs (Dozen)',
        'description': 'Farm fresh eggs, grade A large.',
        'price': 3.49,
        'categoryId': categoryMap['Dairy & Eggs'],
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=800'],
        'stock': 180,
        'isAvailable': true,
      },
      
      // Meat & Seafood
      {
        'name': 'Chicken Breast',
        'description': 'Fresh boneless chicken breast, lean protein.',
        'price': 8.99,
        'categoryId': categoryMap['Meat & Seafood'],
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=800'],
        'stock': 70,
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
      
      // Beverages
      {
        'name': 'Fresh Orange Juice',
        'description': 'Fresh squeezed orange juice, no added sugar.',
        'price': 4.99,
        'categoryId': categoryMap['Beverages'],
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=800'],
        'stock': 90,
        'isAvailable': true,
      },
      
      // Snacks & Sweets
      {
        'name': 'Potato Chips',
        'description': 'Crispy potato chips, classic salted flavor.',
        'price': 2.99,
        'categoryId': categoryMap['Snacks & Sweets'],
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
      
      // Frozen Foods
      {
        'name': 'Pepperoni Pizza',
        'description': 'Delicious frozen pizza, ready in 15 minutes.',
        'price': 6.99,
        'categoryId': categoryMap['Frozen Foods'],
        'categoryName': 'Frozen Foods',
        'imageUrls': ['https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800'],
        'stock': 70,
        'isAvailable': true,
      },
      
      // Pantry & Canned
      {
        'name': 'Pasta (Spaghetti)',
        'description': 'Italian spaghetti pasta, perfect for any sauce.',
        'price': 2.49,
        'categoryId': categoryMap['Pantry & Canned'],
        'categoryName': 'Pantry & Canned',
        'imageUrls': ['https://images.unsplash.com/photo-1551462147-37e8e0f44a1d?w=800'],
        'stock': 150,
        'isAvailable': true,
      },
    ];
  }
}
