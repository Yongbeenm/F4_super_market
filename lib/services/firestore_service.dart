import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Database Service
/// Provides generic CRUD operations and queries for Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Create Operations ====================

  /// Create a new document with auto-generated ID
  Future<String> createDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw 'Failed to create document: $e';
    }
  }

  /// Create or update a document with specific ID
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).set(
            data,
            SetOptions(merge: merge),
          );
    } catch (e) {
      throw 'Failed to set document: $e';
    }
  }

  // ==================== Read Operations ====================

  /// Get a single document by ID
  Future<DocumentSnapshot> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw 'Failed to get document: $e';
    }
  }

  /// Get all documents in a collection
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      throw 'Failed to get collection: $e';
    }
  }

  /// Get documents with a simple where clause
  Future<QuerySnapshot> getWhere(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      return await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
    } catch (e) {
      throw 'Failed to query documents: $e';
    }
  }

  /// Get documents with multiple where clauses
  Future<QuerySnapshot> getWhereMultiple(
    String collection,
    Map<String, dynamic> conditions,
  ) async {
    try {
      Query query = _firestore.collection(collection);
      conditions.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
      return await query.get();
    } catch (e) {
      throw 'Failed to query documents: $e';
    }
  }

  /// Get documents with ordering
  Future<QuerySnapshot> getOrdered(
    String collection,
    String orderBy, {
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection).orderBy(
            orderBy,
            descending: descending,
          );
      if (limit != null) {
        query = query.limit(limit);
      }
      return await query.get();
    } catch (e) {
      throw 'Failed to get ordered documents: $e';
    }
  }

  /// Get documents with pagination
  Future<QuerySnapshot> getPaginated(
    String collection, {
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      return await query.get();
    } catch (e) {
      throw 'Failed to get paginated documents: $e';
    }
  }

  // ==================== Update Operations ====================

  /// Update specific fields in a document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw 'Failed to update document: $e';
    }
  }

  /// Increment a numeric field
  Future<void> incrementField(
    String collection,
    String docId,
    String field,
    num incrementBy,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        field: FieldValue.increment(incrementBy),
      });
    } catch (e) {
      throw 'Failed to increment field: $e';
    }
  }

  /// Add item to array field
  Future<void> arrayUnion(
    String collection,
    String docId,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        field: FieldValue.arrayUnion([value]),
      });
    } catch (e) {
      throw 'Failed to add to array: $e';
    }
  }

  /// Remove item from array field
  Future<void> arrayRemove(
    String collection,
    String docId,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        field: FieldValue.arrayRemove([value]),
      });
    } catch (e) {
      throw 'Failed to remove from array: $e';
    }
  }

  // ==================== Delete Operations ====================

  /// Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw 'Failed to delete document: $e';
    }
  }

  /// Delete a field from a document
  Future<void> deleteField(
    String collection,
    String docId,
    String field,
  ) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        field: FieldValue.delete(),
      });
    } catch (e) {
      throw 'Failed to delete field: $e';
    }
  }

  /// Batch delete documents
  Future<void> batchDelete(
    String collection,
    List<String> docIds,
  ) async {
    try {
      final batch = _firestore.batch();
      for (final docId in docIds) {
        batch.delete(_firestore.collection(collection).doc(docId));
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to batch delete: $e';
    }
  }

  // ==================== Stream Operations ====================

  /// Stream a single document
  Stream<DocumentSnapshot> streamDocument(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Stream all documents in a collection
  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  /// Stream documents with a where clause
  Stream<QuerySnapshot> streamWhere(
    String collection,
    String field,
    dynamic value,
  ) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .snapshots();
  }

  /// Stream documents with ordering
  Stream<QuerySnapshot> streamOrdered(
    String collection,
    String orderBy, {
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection).orderBy(
          orderBy,
          descending: descending,
        );
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  // ==================== Batch Operations ====================

  /// Batch write multiple operations
  Future<void> batchWrite(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;

        final docRef = docId != null
            ? _firestore.collection(collection).doc(docId)
            : _firestore.collection(collection).doc();

        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to execute batch write: $e';
    }
  }

  // ==================== Transaction Operations ====================

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      throw 'Failed to run transaction: $e';
    }
  }

  // ==================== Utility Methods ====================

  /// Check if document exists
  Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw 'Failed to check document existence: $e';
    }
  }

  /// Get document count in collection
  Future<int> getCollectionCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw 'Failed to get collection count: $e';
    }
  }

  /// Search documents (simple text search)
  Future<QuerySnapshot> searchDocuments(
    String collection,
    String field,
    String searchTerm,
  ) async {
    try {
      return await _firestore
          .collection(collection)
          .where(field, isGreaterThanOrEqualTo: searchTerm)
          .where(field, isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();
    } catch (e) {
      throw 'Failed to search documents: $e';
    }
  }
}
