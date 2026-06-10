import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// Address Service
/// Handles delivery address operations
class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Get user's addresses
  Stream<List<Map<String, dynamic>>> getAddresses() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .orderBy('isDefault', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Add new address
  Future<String> addAddress({
    required String label, // Home, Work, Other
    required String fullName,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String zipCode,
    bool isDefault = false,
    double? latitude,
    double? longitude,
    String? locationAddress,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      // If this is default, unset other defaults
      if (isDefault) {
        await _unsetAllDefaults();
      }

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add({
        'label': label,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2 ?? '',
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'isDefault': isDefault,
        'latitude': latitude,
        'longitude': longitude,
        'locationAddress': locationAddress,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw 'Error adding address: $e';
    }
  }

  /// Update address
  Future<void> updateAddress(String addressId, Map<String, dynamic> updates) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      // If setting as default, unset other defaults
      if (updates['isDefault'] == true) {
        await _unsetAllDefaults();
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .update(updates);
    } catch (e) {
      throw 'Error updating address: $e';
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      throw 'Error deleting address: $e';
    }
  }

  /// Set address as default
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not authenticated';
      }

      await _unsetAllDefaults();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .update({'isDefault': true});
    } catch (e) {
      throw 'Error setting default address: $e';
    }
  }

  /// Get default address
  Future<Map<String, dynamic>?> getDefaultAddress() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return null;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Unset all default addresses
  Future<void> _unsetAllDefaults() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    final addresses = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in addresses.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
