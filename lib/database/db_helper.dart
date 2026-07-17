import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/calculation_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance_calcs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE calculations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            inputs TEXT NOT NULL,
            outputs TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertCalculation(CalculationModel calc) async {
    final db = await database;
    return await db.insert('calculations', calc.toMap());
  }

  Future<List<CalculationModel>> getAllCalculations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'calculations',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => CalculationModel.fromMap(maps[i]));
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'calculations',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCalculation(int id) async {
    final db = await database;
    return await db.delete(
      'calculations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('calculations');
  }
}
