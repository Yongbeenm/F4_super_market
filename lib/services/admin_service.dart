import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/sample_data.dart';

/// Admin Service
/// Handles admin operations like uploading sample data
class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin email
  static const String adminEmail = 'yongbeenm@gmail.com';

  /// Check if user is admin
  Future<bool> isAdmin(String email) async {
    return email.toLowerCase() == adminEmail.toLowerCase();
  }

  /// Upload sample data to Firestore
  Future<void> uploadSampleData() async {
    try {
      // Upload categories
      final batch = _firestore.batch();
      
      for (final category in SampleData.categories) {
        final docRef = _firestore.collection('categories').doc();
        batch.set(docRef, {
          ...category,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      
      // Upload products
      final productBatch = _firestore.batch();
      
      for (final product in SampleData.products) {
        final docRef = _firestore.collection('products').doc();
        productBatch.set(docRef, {
          ...product,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await productBatch.commit();
    } catch (e) {
      throw 'Error uploading sample data: $e';
    }
  }

  /// Clear all products and categories
  Future<void> clearDatabase() async {
    try {
      // Delete all products
      final products = await _firestore.collection('products').get();
      final productBatch = _firestore.batch();
      for (final doc in products.docs) {
        productBatch.delete(doc.reference);
      }
      await productBatch.commit();

      // Delete all categories
      final categories = await _firestore.collection('categories').get();
      final categoryBatch = _firestore.batch();
      for (final doc in categories.docs) {
        categoryBatch.delete(doc.reference);
      }
      await categoryBatch.commit();
    } catch (e) {
      throw 'Error clearing database: $e';
    }
  }
}
