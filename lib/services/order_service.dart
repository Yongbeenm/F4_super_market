import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'cart_service.dart';
import 'notification_service.dart';

/// Order Service
/// Handles order operations with Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  final NotificationService _notificationService = NotificationService();

  /// Place an order from cart
  Future<String> placeOrder({
    required String deliveryAddress,
    required String phoneNumber,
    String? notes,
    required String paymentMethod,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      // Get cart items
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      if (cartSnapshot.docs.isEmpty) {
        throw 'Cart is empty';
      }

      // Calculate total
      double total = 0;
      final items = cartSnapshot.docs.map((doc) {
        final data = doc.data();
        final price = (data['price'] as num).toDouble();
        final quantity = data['quantity'] as int;
        total += price * quantity;
        return {
          'productId': data['productId'],
          'productName': data['productName'],
          'price': price,
          'quantity': quantity,
          'imageUrl': data['imageUrl'],
        };
      }).toList();

      final tax = total * 0.1;
      final grandTotal = total + tax;

      // Create order
      final orderRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add({
        'items': items,
        'subtotal': total,
        'tax': tax,
        'total': grandTotal,
        'deliveryAddress': deliveryAddress,
        'phoneNumber': phoneNumber,
        'notes': notes ?? '',
        'paymentMethod': paymentMethod,
        'status': 'pending', // pending, processing, shipped, delivered, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear cart after order
      await _cartService.clearCart();

      // Send order notification
      await _notificationService.showOrderNotification(
        orderId: orderRef.id,
        status: 'pending',
        total: grandTotal,
      );

      return orderRef.id;
    } catch (e) {
      throw 'Error placing order: $e';
    }
  }

  /// Get user's orders
  Stream<List<Map<String, dynamic>>> getOrders() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get single order
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        data?['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw 'Error fetching order: $e';
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send cancellation notification
      await _notificationService.showOrderNotification(
        orderId: orderId,
        status: 'cancelled',
        total: 0,
      );
    } catch (e) {
      throw 'Error cancelling order: $e';
    }
  }

  /// Update order status (Admin function)
  Future<void> updateOrderStatus(String userId, String orderId, String status) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send status update notification
      await _notificationService.showOrderNotification(
        orderId: orderId,
        status: status,
        total: 0,
      );
    } catch (e) {
      throw 'Error updating order status: $e';
    }
  }
}
