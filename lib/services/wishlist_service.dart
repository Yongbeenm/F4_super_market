import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Wishlist Service
/// Handles wishlist operations with Firestore
class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ==================== Wishlist Methods ====================

  /// Get user's wishlist items
  Stream<List<Map<String, dynamic>>> getWishlistItems() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Add item to wishlist
  Future<void> addToWishlist({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .set({
        'productId': productId,
        'productName': productName,
        'price': price,
        'imageUrl': imageUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error adding to wishlist: $e';
    }
  }

  /// Remove item from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .delete();
    } catch (e) {
      throw 'Error removing from wishlist: $e';
    }
  }

  /// Check if item is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return false;
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Toggle wishlist (add if not exists, remove if exists)
  Future<bool> toggleWishlist({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
  }) async {
    try {
      final isInList = await isInWishlist(productId);
      
      if (isInList) {
        await removeFromWishlist(productId);
        return false; // Removed
      } else {
        await addToWishlist(
          productId: productId,
          productName: productName,
          price: price,
          imageUrl: imageUrl,
        );
        return true; // Added
      }
    } catch (e) {
      throw 'Error toggling wishlist: $e';
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final wishlistItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .get();

      final batch = _firestore.batch();
      for (final doc in wishlistItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Error clearing wishlist: $e';
    }
  }

  /// Get wishlist item count
  Future<int> getWishlistCount() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return 0;
      }

      final wishlistItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .get();

      return wishlistItems.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
