import 'package:cloud_firestore/cloud_firestore.dart';

class SampleData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload sample categories (checks for duplicates)
  static Future<void> uploadCategories() async {
    final categories = [
      {
        'name': 'Fruits & Vegetables',
        'imageUrl': 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=500',
        'color': 'green',
        'displayOrder': 1,
      },
      {
        'name': 'Dairy & Eggs',
        'imageUrl': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500',
        'color': 'blue',
        'displayOrder': 2,
      },
      {
        'name': 'Meat & Seafood',
        'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
        'color': 'red',
        'displayOrder': 3,
      },
      {
        'name': 'Bakery & Bread',
        'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500',
        'color': 'brown',
        'displayOrder': 4,
      },
      {
        'name': 'Beverages',
        'imageUrl': 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500',
        'color': 'cyan',
        'displayOrder': 5,
      },
      {
        'name': 'Snacks & Sweets',
        'imageUrl': 'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=500',
        'color': 'orange',
        'displayOrder': 6,
      },
      {
        'name': 'Frozen Foods',
        'imageUrl': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500',
        'color': 'blue',
        'displayOrder': 7,
      },
      {
        'name': 'Pantry Staples',
        'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
        'color': 'yellow',
        'displayOrder': 8,
      },
    ];

    int added = 0;
    int skipped = 0;

    for (var category in categories) {
      // Check if category already exists
      final existing = await _firestore
          .collection('categories')
          .where('name', isEqualTo: category['name'])
          .get();

      if (existing.docs.isEmpty) {
        await _firestore.collection('categories').add(category);
        print('✅ Added category: ${category['name']}');
        added++;
      } else {
        print('⏭️  Skipped (exists): ${category['name']}');
        skipped++;
      }
    }

    print('\n📊 Categories Summary:');
    print('   Added: $added');
    print('   Skipped: $skipped');
  }

  /// Upload sample products (checks for duplicates)
  static Future<void> uploadProducts() async {
    // Get category IDs first
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final categoryMap = <String, String>{};
    
    for (var doc in categoriesSnapshot.docs) {
      final data = doc.data();
      categoryMap[data['name']] = doc.id;
    }

    final products = [
      // Fruits & Vegetables
      {
        'name': 'Fresh Apples',
        'description': 'Crisp and sweet red apples',
        'price': 2.99,
        'stock': 50,
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Bananas',
        'description': 'Fresh yellow bananas',
        'price': 1.99,
        'stock': 100,
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1587049352846-4a222e784422?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Oranges',
        'description': 'Juicy sweet oranges',
        'price': 3.49,
        'stock': 60,
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1553279768-865429fa0078?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Tomatoes',
        'description': 'Fresh red tomatoes',
        'price': 2.49,
        'stock': 40,
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Carrots',
        'description': 'Organic fresh carrots',
        'price': 1.79,
        'stock': 80,
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Lettuce',
        'description': 'Fresh green lettuce',
        'price': 1.99,
        'stock': 30,
        'categoryName': 'Fruits & Vegetables',
        'imageUrls': ['https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=500'],
        'isAvailable': true,
      },

      // Dairy & Eggs
      {
        'name': 'Fresh Milk',
        'description': 'Whole milk 1 gallon',
        'price': 4.99,
        'stock': 50,
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Cheddar Cheese',
        'description': 'Sharp cheddar cheese block',
        'price': 5.99,
        'stock': 30,
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1452195100486-9cc805987862?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Fresh Eggs',
        'description': 'Farm fresh eggs (12 count)',
        'price': 3.99,
        'stock': 60,
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Greek Yogurt',
        'description': 'Plain Greek yogurt',
        'price': 4.49,
        'stock': 40,
        'categoryName': 'Dairy & Eggs',
        'imageUrls': ['https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500'],
        'isAvailable': true,
      },

      // Meat & Seafood
      {
        'name': 'Chicken Breast',
        'description': 'Fresh boneless chicken breast',
        'price': 8.99,
        'stock': 25,
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Ground Beef',
        'description': 'Lean ground beef',
        'price': 7.99,
        'stock': 30,
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Fresh Salmon',
        'description': 'Atlantic salmon fillet',
        'price': 12.99,
        'stock': 15,
        'categoryName': 'Meat & Seafood',
        'imageUrls': ['https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=500'],
        'isAvailable': true,
      },

      // Bakery & Bread
      {
        'name': 'Whole Wheat Bread',
        'description': 'Fresh baked whole wheat bread',
        'price': 3.49,
        'stock': 40,
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Croissants',
        'description': 'Butter croissants (4 pack)',
        'price': 4.99,
        'stock': 20,
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Bagels',
        'description': 'Plain bagels (6 pack)',
        'price': 3.99,
        'stock': 30,
        'categoryName': 'Bakery & Bread',
        'imageUrls': ['https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=500'],
        'isAvailable': true,
      },

      // Beverages
      {
        'name': 'Orange Juice',
        'description': 'Fresh squeezed orange juice',
        'price': 5.99,
        'stock': 35,
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Bottled Water',
        'description': 'Spring water (24 pack)',
        'price': 4.99,
        'stock': 50,
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Coffee Beans',
        'description': 'Premium roasted coffee beans',
        'price': 12.99,
        'stock': 20,
        'categoryName': 'Beverages',
        'imageUrls': ['https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=500'],
        'isAvailable': true,
      },

      // Snacks & Sweets
      {
        'name': 'Potato Chips',
        'description': 'Classic salted potato chips',
        'price': 3.49,
        'stock': 60,
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Chocolate Cookies',
        'description': 'Chocolate chip cookies',
        'price': 4.99,
        'stock': 40,
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=500'],
        'isAvailable': true,
      },
      {
        'name': 'Dark Chocolate',
        'description': 'Premium dark chocolate bar',
        'price': 3.99,
        'stock': 50,
        'categoryName': 'Snacks & Sweets',
        'imageUrls': ['https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=500'],
        'isAvailable': true,
      },
    ];

    int added = 0;
    int skipped = 0;

    for (var product in products) {
      // Check if product already exists
      final existing = await _firestore
          .collection('products')
          .where('name', isEqualTo: product['name'])
          .get();

      if (existing.docs.isEmpty) {
        // Add categoryId
        final categoryName = product['categoryName'] as String;
        product['categoryId'] = categoryMap[categoryName] ?? '';
        
        await _firestore.collection('products').add(product);
        print('✅ Added product: ${product['name']}');
        added++;
      } else {
        print('⏭️  Skipped (exists): ${product['name']}');
        skipped++;
      }
    }

    print('\n📊 Products Summary:');
    print('   Added: $added');
    print('   Skipped: $skipped');
  }

  /// Upload all sample data
  static Future<Map<String, int>> uploadAll() async {
    print('🚀 Starting data upload...\n');
    
    print('📁 Uploading Categories...');
    await uploadCategories();
    
    print('\n📦 Uploading Products...');
    await uploadProducts();
    
    print('\n✅ Data upload complete!');
    
    // Return summary
    final categoriesCount = (await _firestore.collection('categories').get()).docs.length;
    final productsCount = (await _firestore.collection('products').get()).docs.length;
    
    return {
      'categories': categoriesCount,
      'products': productsCount,
    };
  }
}
