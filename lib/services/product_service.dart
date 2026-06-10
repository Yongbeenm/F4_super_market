import 'package:cloud_firestore/cloud_firestore.dart';

/// Product Service
/// Handles product-related operations with Firestore
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Collections ====================
  
  final String _productsCollection = 'products';
  final String _categoriesCollection = 'categories';

  // ==================== Product Methods ====================

  /// Get all products
  Stream<List<Map<String, dynamic>>> getProducts() {
    return _firestore
        .collection(_productsCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get products by category
  Stream<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) {
    return _firestore
        .collection(_productsCollection)
        .where('categoryId', isEqualTo: categoryId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get single product by ID
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      final doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        data?['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw 'Error fetching product: $e';
    }
  }

  /// Search products by name
  Stream<List<Map<String, dynamic>>> searchProducts(String query) {
    return _firestore
        .collection(_productsCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .where((product) {
            final name = (product['name'] as String).toLowerCase();
            return name.contains(query.toLowerCase());
          })
          .toList();
    });
  }

  // ==================== Category Methods ====================

  /// Get all categories
  Stream<List<Map<String, dynamic>>> getCategories() {
    return _firestore
        .collection(_categoriesCollection)
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get single category by ID
  Future<Map<String, dynamic>?> getCategory(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        data?['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw 'Error fetching category: $e';
    }
  }

  // ==================== Admin Methods ====================

  /// Add a new product (Admin only)
  Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore
          .collection(_productsCollection)
          .add(productData);
      
      return docRef.id;
    } catch (e) {
      throw 'Error adding product: $e';
    }
  }

  /// Update product (Admin only)
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update(updates);
    } catch (e) {
      throw 'Error updating product: $e';
    }
  }

  /// Delete product (Admin only)
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw 'Error deleting product: $e';
    }
  }

  /// Add a new category (Admin only)
  Future<String> addCategory(Map<String, dynamic> categoryData) async {
    try {
      categoryData['createdAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore
          .collection(_categoriesCollection)
          .add(categoryData);
      
      return docRef.id;
    } catch (e) {
      throw 'Error adding category: $e';
    }
  }

  /// Update category (Admin only)
  Future<void> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .update(updates);
    } catch (e) {
      throw 'Error updating category: $e';
    }
  }

  /// Batch upload products (Admin only)
  Future<void> batchUploadProducts(List<Map<String, dynamic>> products) async {
    try {
      final batch = _firestore.batch();
      
      for (final product in products) {
        final docRef = _firestore.collection(_productsCollection).doc();
        product['createdAt'] = FieldValue.serverTimestamp();
        product['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(docRef, product);
      }
      
      await batch.commit();
    } catch (e) {
      throw 'Error batch uploading products: $e';
    }
  }

  /// Batch upload categories (Admin only)
  Future<void> batchUploadCategories(List<Map<String, dynamic>> categories) async {
    try {
      final batch = _firestore.batch();
      
      for (final category in categories) {
        final docRef = _firestore.collection(_categoriesCollection).doc();
        category['createdAt'] = FieldValue.serverTimestamp();
        batch.set(docRef, category);
      }
      
      await batch.commit();
    } catch (e) {
      throw 'Error batch uploading categories: $e';
    }
  }
}
