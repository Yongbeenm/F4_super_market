import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item_model.dart';

/// SQLite database helper for local storage
/// Handles cart items and user preferences
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartmart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Cart items table
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL UNIQUE,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        added_at INTEGER NOT NULL
      )
    ''');

    // User preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ==================== Cart Operations ====================

  Future<void> insertCartItem(CartItemModel item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItemModel>> getCartItems() async {
    final db = await database;
    final maps = await db.query('cart_items', orderBy: 'added_at DESC');
    return maps.map((map) => CartItemModel.fromMap(map)).toList();
  }

  Future<CartItemModel?> getCartItem(String productId) async {
    final db = await database;
    final maps = await db.query(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    if (maps.isNotEmpty) {
      return CartItemModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateCartItem(CartItemModel item) async {
    final db = await database;
    await db.update(
      'cart_items',
      item.toMap(),
      where: 'product_id = ?',
      whereArgs: [item.productId],
    );
  }

  Future<void> deleteCartItem(String productId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<int> getCartItemCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cart_items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getCartTotal() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(price * quantity) as total FROM cart_items',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ==================== Preferences Operations ====================

  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPreference(String key) async {
    final db = await database;
    final maps = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  Future<void> deletePreference(String key) async {
    final db = await database;
    await db.delete(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> clearPreferences() async {
    final db = await database;
    await db.delete('user_preferences');
  }

  // ==================== Database Management ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartmart.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
