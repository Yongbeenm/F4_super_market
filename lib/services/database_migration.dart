import 'package:cloud_firestore/cloud_firestore.dart';

/// Database Migration Service
/// Use this to upgrade your Firestore database structure
class DatabaseMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run all pending migrations
  Future<void> runMigrations() async {
    print('🔄 Starting database migrations...');
    
    try {
      // Check current version
      final versionDoc = await _firestore
          .collection('_system')
          .doc('version')
          .get();
      
      final currentVersion = versionDoc.exists 
          ? (versionDoc.data()?['version'] as int? ?? 0)
          : 0;
      
      print('📊 Current database version: $currentVersion');
      
      // Run migrations based on version
      if (currentVersion < 1) {
        await _migrationV1();
      }
      
      if (currentVersion < 2) {
        await _migrationV2();
      }
      
      // Add more migrations here as needed
      
      print('✅ All migrations completed successfully!');
    } catch (e) {
      print('❌ Migration failed: $e');
      rethrow;
    }
  }

  /// Migration V1: Add featured and tags fields to products
  Future<void> _migrationV1() async {
    print('🔧 Running Migration V1: Add featured and tags to products');
    
    final products = await _firestore.collection('products').get();
    final batch = _firestore.batch();
    
    for (var doc in products.docs) {
      final data = doc.data();
      
      // Only update if fields don't exist
      if (!data.containsKey('featured')) {
        batch.update(doc.reference, {
          'featured': false,
          'tags': [],
          'discount': 0.0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    
    await batch.commit();
    
    // Update version
    await _updateVersion(1);
    
    print('✅ Migration V1 completed: Updated ${products.docs.length} products');
  }

  /// Migration V2: Create reviews collection structure
  Future<void> _migrationV2() async {
    print('🔧 Running Migration V2: Setup reviews collection');
    
    // Create a sample review document to establish collection
    await _firestore.collection('reviews').doc('_sample').set({
      'productId': '_sample',
      'userId': '_sample',
      'rating': 5,
      'comment': 'Sample review - can be deleted',
      'createdAt': FieldValue.serverTimestamp(),
      '_isSample': true,
    });
    
    // Update version
    await _updateVersion(2);
    
    print('✅ Migration V2 completed: Reviews collection created');
  }

  /// Update database version
  Future<void> _updateVersion(int version) async {
    await _firestore.collection('_system').doc('version').set({
      'version': version,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get current database version
  Future<int> getCurrentVersion() async {
    final versionDoc = await _firestore
        .collection('_system')
        .doc('version')
        .get();
    
    return versionDoc.exists 
        ? (versionDoc.data()?['version'] as int? ?? 0)
        : 0;
  }

  // ==================== Specific Migration Methods ====================

  /// Add a new field to all documents in a collection
  Future<void> addFieldToCollection(
    String collection,
    String fieldName,
    dynamic defaultValue,
  ) async {
    print('Adding field "$fieldName" to collection "$collection"...');
    
    final docs = await _firestore.collection(collection).get();
    final batch = _firestore.batch();
    
    int updateCount = 0;
    for (var doc in docs.docs) {
      if (!doc.data().containsKey(fieldName)) {
        batch.update(doc.reference, {
          fieldName: defaultValue,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updateCount++;
      }
    }
    
    await batch.commit();
    print('✅ Updated $updateCount documents');
  }

  /// Remove a field from all documents in a collection
  Future<void> removeFieldFromCollection(
    String collection,
    String fieldName,
  ) async {
    print('Removing field "$fieldName" from collection "$collection"...');
    
    final docs = await _firestore.collection(collection).get();
    final batch = _firestore.batch();
    
    for (var doc in docs.docs) {
      if (doc.data().containsKey(fieldName)) {
        batch.update(doc.reference, {
          fieldName: FieldValue.delete(),
        });
      }
    }
    
    await batch.commit();
    print('✅ Removed field from ${docs.docs.length} documents');
  }

  /// Rename a field in all documents
  Future<void> renameField(
    String collection,
    String oldFieldName,
    String newFieldName,
  ) async {
    print('Renaming field "$oldFieldName" to "$newFieldName" in "$collection"...');
    
    final docs = await _firestore.collection(collection).get();
    final batch = _firestore.batch();
    
    for (var doc in docs.docs) {
      final data = doc.data();
      if (data.containsKey(oldFieldName)) {
        batch.update(doc.reference, {
          newFieldName: data[oldFieldName],
          oldFieldName: FieldValue.delete(),
        });
      }
    }
    
    await batch.commit();
    print('✅ Renamed field in ${docs.docs.length} documents');
  }

  /// Backup collection to a new collection
  Future<void> backupCollection(String collection) async {
    final backupName = '${collection}_backup_${DateTime.now().millisecondsSinceEpoch}';
    print('Backing up "$collection" to "$backupName"...');
    
    final docs = await _firestore.collection(collection).get();
    final batch = _firestore.batch();
    
    for (var doc in docs.docs) {
      final backupRef = _firestore.collection(backupName).doc(doc.id);
      batch.set(backupRef, doc.data());
    }
    
    await batch.commit();
    print('✅ Backed up ${docs.docs.length} documents to "$backupName"');
  }
}
