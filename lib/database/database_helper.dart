import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'monitoring_offline.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Temuan
    await db.execute('''
      CREATE TABLE temuan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal INTEGER NOT NULL,
        jenis_temuan TEXT NOT NULL,
        jalur TEXT NOT NULL,
        lajur TEXT NOT NULL,
        kilometer TEXT NOT NULL,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        foto_path TEXT
      )
    ''');

    // Tabel Perbaikan
    await db.execute('''
      CREATE TABLE perbaikan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal INTEGER NOT NULL,
        jenis_perbaikan TEXT NOT NULL,
        jalur TEXT NOT NULL,
        lajur TEXT NOT NULL,
        kilometer TEXT NOT NULL,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        status_perbaikan TEXT NOT NULL,
        foto_path TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambahkan kolom kilometer, latitude, dan longitude ke tabel temuan
      await db.execute('ALTER TABLE temuan ADD COLUMN kilometer TEXT');
      await db.execute('ALTER TABLE temuan ADD COLUMN latitude TEXT');
      await db.execute('ALTER TABLE temuan ADD COLUMN longitude TEXT');
      
      // Tambahkan kolom kilometer, latitude, dan longitude ke tabel perbaikan
      await db.execute('ALTER TABLE perbaikan ADD COLUMN kilometer TEXT');
      await db.execute('ALTER TABLE perbaikan ADD COLUMN latitude TEXT');
      await db.execute('ALTER TABLE perbaikan ADD COLUMN longitude TEXT');
    }
  }

  // CRUD Operations untuk Temuan
  Future<int> insertTemuan(Temuan temuan) async {
    final db = await database;
    return await db.insert('temuan', temuan.toMap());
  }

  Future<List<Temuan>> getAllTemuan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('temuan');
    return List.generate(maps.length, (i) => Temuan.fromMap(maps[i]));
  }

  Future<List<Temuan>> getTemuanByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'temuan',
      where: 'tanggal >= ? AND tanggal <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Temuan.fromMap(maps[i]));
  }

  Future<int> updateTemuan(Temuan temuan) async {
    final db = await database;
    return await db.update(
      'temuan',
      temuan.toMap(),
      where: 'id = ?',
      whereArgs: [temuan.id],
    );
  }

  Future<int> deleteTemuan(int id) async {
    final db = await database;
    return await db.delete(
      'temuan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations untuk Perbaikan
  Future<int> insertPerbaikan(Perbaikan perbaikan) async {
    final db = await database;
    return await db.insert('perbaikan', perbaikan.toMap());
  }

  Future<List<Perbaikan>> getAllPerbaikan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('perbaikan');
    return List.generate(maps.length, (i) => Perbaikan.fromMap(maps[i]));
  }

  Future<List<Perbaikan>> getPerbaikanByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'perbaikan',
      where: 'tanggal >= ? AND tanggal <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Perbaikan.fromMap(maps[i]));
  }

  Future<int> updatePerbaikan(Perbaikan perbaikan) async {
    final db = await database;
    return await db.update(
      'perbaikan',
      perbaikan.toMap(),
      where: 'id = ?',
      whereArgs: [perbaikan.id],
    );
  }

  Future<int> deletePerbaikan(int id) async {
    final db = await database;
    return await db.delete(
      'perbaikan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
