import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Cart Service
/// Handles cart operations with Firestore
class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // ==================== Cart Methods ====================

  /// Get user's cart items
  Stream<List<Map<String, dynamic>>> getCartItems() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Add item to cart
  Future<void> addToCart({
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    int quantity = 1,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId);

      final doc = await cartRef.get();

      if (doc.exists) {
        // Update quantity if item already exists
        final currentQuantity = doc.data()?['quantity'] ?? 0;
        await cartRef.update({
          'quantity': currentQuantity + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        await cartRef.set({
          'productId': productId,
          'productName': productName,
          'price': price,
          'imageUrl': imageUrl,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Error adding to cart: $e';
    }
  }

  /// Update cart item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      if (quantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error updating quantity: $e';
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (e) {
      throw 'Error removing from cart: $e';
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      final batch = _firestore.batch();
      for (final doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Error clearing cart: $e';
    }
  }

  /// Get cart total
  Future<double> getCartTotal() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return 0.0;
      }

      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      double total = 0.0;
      for (final doc in cartItems.docs) {
        final data = doc.data();
        final price = (data['price'] as num).toDouble();
        final quantity = data['quantity'] as int;
        total += price * quantity;
      }

      return total;
    } catch (e) {
      throw 'Error calculating cart total: $e';
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return 0;
      }

      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      int count = 0;
      for (final doc in cartItems.docs) {
        final data = doc.data();
        count += data['quantity'] as int;
      }

      return count;
    } catch (e) {
      throw 'Error getting cart count: $e';
    }
  }
}
