import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

/// Offline Manager Service
/// Handles offline data caching and synchronization
class OfflineManager {
  static Database? _database;
  static final OfflineManager _instance = OfflineManager._internal();
  
  factory OfflineManager() => _instance;
  
  OfflineManager._internal();

  // ==================== Database Initialization ====================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'f4_supermarket_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        role TEXT,
        lastSync INTEGER
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        price REAL,
        categoryId TEXT,
        imageUrls TEXT,
        stock INTEGER,
        isAvailable INTEGER,
        lastSync INTEGER
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        categoryId TEXT,
        name TEXT,
        imageUrl TEXT,
        displayOrder INTEGER,
        lastSync INTEGER
      )
    ''');

    // Cart table (offline cart)
    await db.execute('''
      CREATE TABLE cart (
        id TEXT PRIMARY KEY,
        userId TEXT,
        productId TEXT,
        productName TEXT,
        price REAL,
        imageUrl TEXT,
        quantity INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Wishlist table (offline wishlist)
    await db.execute('''
      CREATE TABLE wishlist (
        id TEXT PRIMARY KEY,
        userId TEXT,
        productId TEXT,
        productName TEXT,
        price REAL,
        imageUrl TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Pending sync operations
    await db.execute('''
      CREATE TABLE pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT,
        collection TEXT,
        documentId TEXT,
        data TEXT,
        timestamp INTEGER
      )
    ''');
  }

  // ==================== Connectivity Check ====================

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }

  // ==================== User Cache ====================

  Future<void> cacheUser(String userId, Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': userId,
        'name': userData['name'],
        'email': userData['email'],
        'role': userData['role'],
        'lastSync': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedUser(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  // ==================== Products Cache ====================

  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    final batch = db.batch();

    for (final product in products) {
      batch.insert(
        'products',
        {
          'id': product['id'],
          'name': product['name'],
          'description': product['description'],
          'price': product['price'],
          'categoryId': product['categoryId'],
          'imageUrls': jsonEncode(product['imageUrls']),
          'stock': product['stock'],
          'isAvailable': product['isAvailable'] ? 1 : 0,
          'lastSync': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedProducts() async {
    final db = await database;
    final results = await db.query('products');

    return results.map((row) {
      return {
        'id': row['id'],
        'name': row['name'],
        'description': row['description'],
        'price': row['price'],
        'categoryId': row['categoryId'],
        'imageUrls': jsonDecode(row['imageUrls'] as String),
        'stock': row['stock'],
        'isAvailable': (row['isAvailable'] as int) == 1,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getCachedProductsByCategory(
      String categoryId) async {
    final db = await database;
    final results = await db.query(
      'products',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return results.map((row) {
      return {
        'id': row['id'],
        'name': row['name'],
        'description': row['description'],
        'price': row['price'],
        'categoryId': row['categoryId'],
        'imageUrls': jsonDecode(row['imageUrls'] as String),
        'stock': row['stock'],
        'isAvailable': (row['isAvailable'] as int) == 1,
      };
    }).toList();
  }

  // ==================== Categories Cache ====================

  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    final batch = db.batch();

    for (final category in categories) {
      batch.insert(
        'categories',
        {
          'id': category['id'],
          'categoryId': category['categoryId'],
          'name': category['name'],
          'imageUrl': category['imageUrl'],
          'displayOrder': category['displayOrder'],
          'lastSync': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedCategories() async {
    final db = await database;
    final results = await db.query(
      'categories',
      orderBy: 'displayOrder ASC',
    );

    return results.map((row) {
      return {
        'id': row['id'],
        'categoryId': row['categoryId'],
        'name': row['name'],
        'imageUrl': row['imageUrl'],
        'displayOrder': row['displayOrder'],
      };
    }).toList();
  }

  // ==================== Offline Cart ====================

  Future<void> addToOfflineCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
    required int quantity,
  }) async {
    final db = await database;
    await db.insert(
      'cart',
      {
        'id': '$userId-$productId',
        'userId': userId,
        'productId': productId,
        'productName': productName,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getOfflineCart(String userId) async {
    final db = await database;
    final results = await db.query(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return results.toList();
  }

  Future<void> removeFromOfflineCart(String userId, String productId) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: ['$userId-$productId'],
    );
  }

  Future<void> clearOfflineCart(String userId) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ==================== Offline Wishlist ====================

  Future<void> addToOfflineWishlist({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String imageUrl,
  }) async {
    final db = await database;
    await db.insert(
      'wishlist',
      {
        'id': '$userId-$productId',
        'userId': userId,
        'productId': productId,
        'productName': productName,
        'price': price,
        'imageUrl': imageUrl,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getOfflineWishlist(String userId) async {
    final db = await database;
    final results = await db.query(
      'wishlist',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return results.toList();
  }

  Future<void> removeFromOfflineWishlist(
      String userId, String productId) async {
    final db = await database;
    await db.delete(
      'wishlist',
      where: 'id = ?',
      whereArgs: ['$userId-$productId'],
    );
  }

  // ==================== Pending Sync Operations ====================

  Future<void> addPendingSync({
    required String operation,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('pending_sync', {
      'operation': operation,
      'collection': collection,
      'documentId': documentId,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final db = await database;
    return await db.query('pending_sync', orderBy: 'timestamp ASC');
  }

  Future<void> clearPendingSync(int id) async {
    final db = await database;
    await db.delete('pending_sync', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Clear All Cache ====================

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('users');
    await db.delete('products');
    await db.delete('categories');
    await db.delete('cart');
    await db.delete('wishlist');
    await db.delete('pending_sync');
  }
}
