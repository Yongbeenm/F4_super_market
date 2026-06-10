class CartItemModel {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;
  final DateTime addedAt;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.addedAt,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['product_id'] ?? map['productId'] ?? '',
      productName: map['product_name'] ?? map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['image_url'] ?? map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
      addedAt: map['added_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['added_at'])
          : (map['addedAt'] != null
              ? DateTime.parse(map['addedAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
      'added_at': addedAt.millisecondsSinceEpoch,
    };
  }

  factory CartItemModel.fromFirestore(Map<String, dynamic> data) {
    return CartItemModel(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
      addedAt: data['addedAt'] != null
          ? DateTime.parse(data['addedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItemModel copyWith({
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}
