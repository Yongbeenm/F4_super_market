import 'package:cloud_firestore/cloud_firestore.dart';
import 'sample_data.dart';

/// Upload Sample Data to Firebase
/// Run this once to populate your Firestore database with sample products and categories
class UploadSampleDataToFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload all sample data (categories and products)
  Future<void> uploadAll() async {
    try {
      print('Starting data upload...');
      
      await uploadCategories();
      await uploadProducts();
      
      print('✅ All data uploaded successfully!');
    } catch (e) {
      print('❌ Error uploading data: $e');
      rethrow;
    }
  }

  /// Upload categories to Firestore
  Future<void> uploadCategories() async {
    try {
      print('Uploading categories...');
      
      final batch = _firestore.batch();
      
      for (final category in SampleData.categories) {
        final docRef = _firestore.collection('categories').doc(category['categoryId']);
        batch.set(docRef, {
          ...category,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      print('✅ ${SampleData.categories.length} categories uploaded');
    } catch (e) {
      print('❌ Error uploading categories: $e');
      rethrow;
    }
  }

  /// Upload products to Firestore
  Future<void> uploadProducts() async {
    try {
      print('Uploading products...');
      
      // Firestore batch has a limit of 500 operations
      // Split into batches if needed
      final batchSize = 500;
      final products = SampleData.products;
      
      for (var i = 0; i < products.length; i += batchSize) {
        final batch = _firestore.batch();
        final end = (i + batchSize < products.length) ? i + batchSize : products.length;
        
        for (var j = i; j < end; j++) {
          final product = products[j];
          final docRef = _firestore.collection('products').doc();
          batch.set(docRef, {
            ...product,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        await batch.commit();
        print('✅ Uploaded batch ${(i ~/ batchSize) + 1}');
      }
      
      print('✅ ${products.length} products uploaded');
    } catch (e) {
      print('❌ Error uploading products: $e');
      rethrow;
    }
  }

  /// Clear all data (use with caution!)
  Future<void> clearAllData() async {
    try {
      print('⚠️  Clearing all data...');
      
      await _clearCollection('categories');
      await _clearCollection('products');
      
      print('✅ All data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Clear a specific collection
  Future<void> _clearCollection(String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();
    final batch = _firestore.batch();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('✅ Cleared $collectionName collection');
  }
}

/// Helper function to run the upload
Future<void> runUpload() async {
  final uploader = UploadSampleDataToFirebase();
  await uploader.uploadAll();
}
