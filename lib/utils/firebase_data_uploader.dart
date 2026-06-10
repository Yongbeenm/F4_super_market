import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Data Uploader
/// Uploads categories and products to Firebase
class FirebaseDataUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload all data (categories + products)
  Future<Map<String, dynamic>> uploadAllData() async {
    try {
      print('🚀 Starting data upload...');
      
      // Step 1: Upload categories
      print('📂 Uploading categories...');
      final categoryIds = await _uploadCategories();
      print('✅ Uploaded ${categoryIds.length} categories');
      
      // Step 2: Upload products
      print('📦 Uploading products...');
      final productCount = await _uploadProducts(categoryIds);
      print('✅ Uploaded $productCount products');
      
      return {
        'success': true,
        'categories': categoryIds.length,
        'products': productCount,
        'message': 'Successfully uploaded ${categoryIds.length} categories and $productCount products!',
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Upload categories to Firebase
  Future<Map<String, String>> _uploadCategories() async {
    final categories = [
      {'name': 'Fruits', 'imageUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=800', 'displayOrder': 1},
      {'name': 'Vegetables', 'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800', 'displayOrder': 2},
      {'name': 'Dairy', 'imageUrl': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=800', 'displayOrder': 3},
      {'name': 'Bakery', 'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800', 'displayOrder': 4},
      {'name': 'Meat', 'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=800', 'displayOrder': 5},
      {'name': 'Snacks', 'imageUrl': 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=800', 'displayOrder': 6},
      {'name': 'Beverages', 'imageUrl': 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?w=800', 'displayOrder': 7},
      {'name': 'Frozen', 'imageUrl': 'https://images.unsplash.com/photo-1476887334197-56adbf254e1a?w=800', 'displayOrder': 8},
      {'name': 'Pantry', 'imageUrl': 'https://images.unsplash.com/photo-1556910110-a5a63dfd393c?w=800', 'displayOrder': 9},
    ];

    final Map<String, String> categoryIds = {};

    for (var category in categories) {
      final docRef = await _firestore.collection('categories').add({
        ...category,
        'createdAt': FieldValue.serverTimestamp(),
      });
      categoryIds[category['name'] as String] = docRef.id;
      print('  ✓ ${category['name']}');
    }

    return categoryIds;
  }

  /// Upload products to Firebase
  Future<int> _uploadProducts(Map<String, String> categoryIds) async {
    int count = 0;

    // Fruits
    final fruits = [
      {'name': 'Red Apples', 'description': 'Fresh, crisp red apples', 'price': 2.99, 'stock': 150, 'imageUrls': ['https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800']},
      {'name': 'Bananas', 'description': 'Ripe yellow bananas', 'price': 1.99, 'stock': 200, 'imageUrls': ['https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800']},
      {'name': 'Strawberries', 'description': 'Sweet, juicy strawberries', 'price': 4.99, 'stock': 80, 'imageUrls': ['https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800']},
      {'name': 'Oranges', 'description': 'Juicy navel oranges', 'price': 3.49, 'stock': 120, 'imageUrls': ['https://images.unsplash.com/photo-1547514701-42782101795e?w=800']},
      {'name': 'Blueberries', 'description': 'Fresh organic blueberries', 'price': 5.99, 'stock': 60, 'imageUrls': ['https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=800']},
    ];
    count += await _uploadCategoryProducts('Fruits', fruits, categoryIds);

    // Vegetables
    final vegetables = [
      {'name': 'Broccoli', 'description': 'Fresh green broccoli crowns', 'price': 2.49, 'stock': 90, 'imageUrls': ['https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=800']},
      {'name': 'Carrots', 'description': 'Crunchy orange carrots', 'price': 1.99, 'stock': 150, 'imageUrls': ['https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=800']},
      {'name': 'Tomatoes', 'description': 'Ripe red tomatoes', 'price': 3.29, 'stock': 110, 'imageUrls': ['https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=800']},
      {'name': 'Lettuce', 'description': 'Fresh crisp lettuce', 'price': 2.29, 'stock': 75, 'imageUrls': ['https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=800']},
      {'name': 'Bell Peppers', 'description': 'Colorful bell peppers', 'price': 3.99, 'stock': 85, 'imageUrls': ['https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=800']},
    ];
    count += await _uploadCategoryProducts('Vegetables', vegetables, categoryIds);

    // Dairy
    final dairy = [
      {'name': 'Whole Milk', 'description': 'Fresh whole milk, 1 gallon', 'price': 4.99, 'stock': 200, 'imageUrls': ['https://images.unsplash.com/photo-1550583724-b2692b25a968?w=800']},
      {'name': 'Cheddar Cheese', 'description': 'Sharp cheddar cheese', 'price': 5.99, 'stock': 120, 'imageUrls': ['https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=800']},
      {'name': 'Greek Yogurt', 'description': 'Creamy Greek yogurt', 'price': 3.99, 'stock': 150, 'imageUrls': ['https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800']},
      {'name': 'Butter', 'description': 'Unsalted butter', 'price': 4.49, 'stock': 100, 'imageUrls': ['https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=800']},
    ];
    count += await _uploadCategoryProducts('Dairy', dairy, categoryIds);

    // Bakery
    final bakery = [
      {'name': 'Whole Wheat Bread', 'description': 'Fresh baked whole wheat bread', 'price': 3.49, 'stock': 80, 'imageUrls': ['https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800']},
      {'name': 'Croissants', 'description': 'Buttery French croissants', 'price': 4.99, 'stock': 60, 'imageUrls': ['https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800']},
      {'name': 'Bagels', 'description': 'Fresh plain bagels', 'price': 3.99, 'stock': 90, 'imageUrls': ['https://images.unsplash.com/photo-1551106652-a5bcf4b29ab6?w=800']},
    ];
    count += await _uploadCategoryProducts('Bakery', bakery, categoryIds);

    // Meat
    final meat = [
      {'name': 'Chicken Breast', 'description': 'Fresh boneless chicken breast', 'price': 8.99, 'stock': 70, 'imageUrls': ['https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=800']},
      {'name': 'Salmon Fillet', 'description': 'Fresh Atlantic salmon', 'price': 12.99, 'stock': 50, 'imageUrls': ['https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=800']},
      {'name': 'Ground Beef', 'description': 'Lean ground beef', 'price': 7.99, 'stock': 85, 'imageUrls': ['https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=800']},
    ];
    count += await _uploadCategoryProducts('Meat', meat, categoryIds);

    // Snacks
    final snacks = [
      {'name': 'Potato Chips', 'description': 'Crispy potato chips', 'price': 2.99, 'stock': 150, 'imageUrls': ['https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=800']},
      {'name': 'Mixed Nuts', 'description': 'Premium mixed nuts', 'price': 6.99, 'stock': 100, 'imageUrls': ['https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73?w=800']},
      {'name': 'Chocolate Bar', 'description': 'Premium dark chocolate', 'price': 3.49, 'stock': 120, 'imageUrls': ['https://images.unsplash.com/photo-1511381939415-e44015466834?w=800']},
    ];
    count += await _uploadCategoryProducts('Snacks', snacks, categoryIds);

    // Beverages
    final beverages = [
      {'name': 'Orange Juice', 'description': 'Fresh squeezed orange juice', 'price': 4.99, 'stock': 90, 'imageUrls': ['https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=800']},
      {'name': 'Sparkling Water', 'description': 'Refreshing sparkling water', 'price': 3.99, 'stock': 130, 'imageUrls': ['https://images.unsplash.com/photo-1523362628745-0c100150b504?w=800']},
      {'name': 'Green Tea', 'description': 'Premium green tea bags', 'price': 5.49, 'stock': 80, 'imageUrls': ['https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=800']},
    ];
    count += await _uploadCategoryProducts('Beverages', beverages, categoryIds);

    // Frozen
    final frozen = [
      {'name': 'Frozen Pizza', 'description': 'Delicious frozen pizza', 'price': 6.99, 'stock': 70, 'imageUrls': ['https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800']},
      {'name': 'Ice Cream', 'description': 'Premium vanilla ice cream', 'price': 5.99, 'stock': 95, 'imageUrls': ['https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=800']},
      {'name': 'Frozen Vegetables', 'description': 'Mixed frozen vegetables', 'price': 3.99, 'stock': 110, 'imageUrls': ['https://images.unsplash.com/photo-1590301157890-4810ed352733?w=800']},
    ];
    count += await _uploadCategoryProducts('Frozen', frozen, categoryIds);

    // Pantry
    final pantry = [
      {'name': 'Pasta', 'description': 'Italian spaghetti pasta', 'price': 2.49, 'stock': 150, 'imageUrls': ['https://images.unsplash.com/photo-1551462147-37e8e0f44a1d?w=800']},
      {'name': 'Tomato Sauce', 'description': 'Classic tomato sauce', 'price': 3.49, 'stock': 120, 'imageUrls': ['https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=800']},
      {'name': 'Rice', 'description': 'Long grain white rice', 'price': 6.99, 'stock': 90, 'imageUrls': ['https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800']},
    ];
    count += await _uploadCategoryProducts('Pantry', pantry, categoryIds);

    return count;
  }

  Future<int> _uploadCategoryProducts(
    String categoryName,
    List<Map<String, dynamic>> products,
    Map<String, String> categoryIds,
  ) async {
    final categoryId = categoryIds[categoryName];
    if (categoryId == null) return 0;

    for (var product in products) {
      await _firestore.collection('products').add({
        ...product,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('  ✓ ${product['name']}');
    }

    return products.length;
  }
}
