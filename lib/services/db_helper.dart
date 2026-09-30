import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

// Gestor de la base de datos SQLite relacional
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventario_sistema_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // Creación de las tablas 'users' y 'products'
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        sku TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT NOT NULL,
        purchasePrice REAL NOT NULL,
        salePrice REAL NOT NULL,
        taxPercentage REAL NOT NULL,
        stock INTEGER NOT NULL,
        minStock INTEGER NOT NULL,
        reorderPoint INTEGER NOT NULL,
        batchNumber TEXT NOT NULL,
        expirationDate TEXT NOT NULL,
        supplier TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // --- REGISTRO Y LOGIN DE USUARIOS ---

  Future<int> registerUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), password.trim()],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim()],
    );
    return result.isNotEmpty;
  }

  // --- CRUD DE PRODUCTOS ---

  Future<int> insertProduct(ProductModel product) async {
    final db = await instance.database;
    return await db.insert('products', product.toMap());
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'id DESC');
    return result.map((map) => ProductModel.fromMap(map)).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final list = await getProducts();
    double totalValue = 0;
    int criticalCount = 0;

    for (var item in list) {
      totalValue += item.totalValue;
      if (item.isLowStock) criticalCount++;
    }

    return {
      'totalProducts': list.length,
      'totalValue': totalValue,
      'criticalCount': criticalCount,
    };
  }
}