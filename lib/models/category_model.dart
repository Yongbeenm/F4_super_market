import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String categoryId;
  final String name;
  final String? imageUrl;
  final int displayOrder;

  CategoryModel({
    required this.categoryId,
    required this.name,
    this.imageUrl,
    required this.displayOrder,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      categoryId: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'name': name,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
    };
  }

  CategoryModel copyWith({
    String? categoryId,
    String? name,
    String? imageUrl,
    int? displayOrder,
  }) {
    return CategoryModel(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;
}
