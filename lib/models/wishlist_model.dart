import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String userId;
  final List<String> productIds;
  final DateTime updatedAt;

  WishlistModel({
    required this.userId,
    required this.productIds,
    required this.updatedAt,
  });

  factory WishlistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistModel(
      userId: doc.id,
      productIds: List<String>.from(data['productIds'] ?? []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productIds': productIds,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  WishlistModel copyWith({
    String? userId,
    List<String>? productIds,
    DateTime? updatedAt,
  }) {
    return WishlistModel(
      userId: userId ?? this.userId,
      productIds: productIds ?? this.productIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool contains(String productId) {
    return productIds.contains(productId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
