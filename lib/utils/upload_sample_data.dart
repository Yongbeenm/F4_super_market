import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sample_data.dart';

/// Upload Sample Data to Firebase
/// Run this once to populate your Firestore database with sample data
class UploadSampleData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload all sample data to Firestore
  static Future<void> uploadAll() async {
    try {
      print('🚀 Starting sample data upload...\n');

      // 1. Upload Categories
      await uploadCategories();

      // 2. Upload Products
      await uploadProducts();

      // 3. Create Sample Users (optional)
      await createSampleUsers();

      print('\n✅ All sample data uploaded successfully!');
      print('📊 Summary:');
      print('   - ${SampleData.categories.length} categories');
      print('   - ${SampleData.products.length} products');
      print('   - ${SampleData.users.length} sample users');
    } catch (e) {
      print('❌ Error uploading sample data: $e');
      rethrow;
    }
  }

  /// Upload Categories to Firestore
  static Future<void> uploadCategories() async {
    print('📦 Uploading categories...');
    
    final batch = _firestore.batch();
    int count = 0;

    for (var category in SampleData.categories) {
      final docRef = _firestore
          .collection('categories')
          .doc(category['categoryId']);
      
      batch.set(docRef, {
        'categoryId': category['categoryId'],
        'name': category['name'],
        'imageUrl': category['imageUrl'],
        'displayOrder': category['displayOrder'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      count++;
    }

    await batch.commit();
    print('   ✓ Uploaded $count categories');
  }

  /// Upload Products to Firestore
  static Future<void> uploadProducts() async {
    print('🛍️  Uploading products...');
    
    int count = 0;
    int batchCount = 0;
    var batch = _firestore.batch();

    for (var product in SampleData.products) {
      final docRef = _firestore.collection('products').doc();
      
      batch.set(docRef, {
        'productId': docRef.id,
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'categoryId': product['categoryId'],
        'imageUrls': product['imageUrls'],
        'stock': product['stock'],
        'isAvailable': product['isAvailable'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      count++;
      batchCount++;

      // Firestore batch limit is 500 operations
      if (batchCount >= 500) {
        await batch.commit();
        batch = _firestore.batch();
        batchCount = 0;
        print('   ✓ Uploaded $count products so far...');
      }
    }

    // Commit remaining batch
    if (batchCount > 0) {
      await batch.commit();
    }

    print('   ✓ Uploaded $count products');
  }

  /// Create Sample Users (for testing)
  static Future<void> createSampleUsers() async {
    print('👥 Creating sample users...');
    
    int count = 0;

    for (var userData in SampleData.users) {
      try {
        // Skip admin user creation (create manually)
        if (userData['role'] == 'admin') {
          print('   ⚠️  Skipping admin user (create manually)');
          continue;
        }

        // Create user in Firebase Auth
        final email = userData['email'] as String;
        final password = 'password123'; // Default password for sample users

        UserCredential userCredential;
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          // User might already exist
          print('   ⚠️  User $email already exists, skipping...');
          continue;
        }

        final userId = userCredential.user!.uid;

        // Create user document in Firestore
        await _firestore.collection('users').doc(userId).set({
          'userId': userId,
          'name': userData['name'],
          'email': email,
          'phoneNumber': userData['phoneNumber'],
          'role': userData['role'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        count++;
        print('   ✓ Created user: ${userData['name']} ($email)');
      } catch (e) {
        print('   ❌ Error creating user ${userData['email']}: $e');
      }
    }

    print('   ✓ Created $count sample users');
    print('   ℹ️  Default password for sample users: password123');
  }

  /// Clear all sample data (use with caution!)
  static Future<void> clearAll() async {
    print('🗑️  Clearing all sample data...');
    
    try {
      // Clear categories
      final categoriesSnapshot = await _firestore.collection('categories').get();
      for (var doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
      }
      print('   ✓ Cleared ${categoriesSnapshot.docs.length} categories');

      // Clear products
      final productsSnapshot = await _firestore.collection('products').get();
      for (var doc in productsSnapshot.docs) {
        await doc.reference.delete();
      }
      print('   ✓ Cleared ${productsSnapshot.docs.length} products');

      print('✅ All sample data cleared!');
      print('⚠️  Note: User accounts in Firebase Auth were not deleted');
    } catch (e) {
      print('❌ Error clearing sample data: $e');
      rethrow;
    }
  }

  /// Upload only categories
  static Future<void> uploadCategoriesOnly() async {
    print('📦 Uploading categories only...');
    await uploadCategories();
    print('✅ Categories uploaded!');
  }

  /// Upload only products
  static Future<void> uploadProductsOnly() async {
    print('🛍️  Uploading products only...');
    await uploadProducts();
    print('✅ Products uploaded!');
  }

  /// Check if data already exists
  static Future<bool> hasExistingData() async {
    final categoriesSnapshot = await _firestore
        .collection('categories')
        .limit(1)
        .get();
    
    final productsSnapshot = await _firestore
        .collection('products')
        .limit(1)
        .get();

    return categoriesSnapshot.docs.isNotEmpty || 
           productsSnapshot.docs.isNotEmpty;
  }

  /// Get data statistics
  static Future<Map<String, int>> getDataStats() async {
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final productsSnapshot = await _firestore.collection('products').get();
    final usersSnapshot = await _firestore.collection('users').get();
    final ordersSnapshot = await _firestore.collection('orders').get();

    return {
      'categories': categoriesSnapshot.docs.length,
      'products': productsSnapshot.docs.length,
      'users': usersSnapshot.docs.length,
      'orders': ordersSnapshot.docs.length,
    };
  }
}
