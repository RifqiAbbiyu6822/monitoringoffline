import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'monitoring_offline.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel untuk Temuan (Inspeksi Harian)
    await db.execute('''
      CREATE TABLE temuan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deskripsi TEXT NOT NULL,
        foto_path TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        created_date TEXT NOT NULL
      )
    ''');

    // Tabel untuk Proyek Perbaikan
    await db.execute('''
      CREATE TABLE perbaikan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_proyek TEXT NOT NULL,
        deskripsi TEXT,
        status INTEGER DEFAULT 0,
        created_date TEXT NOT NULL,
        updated_date TEXT NOT NULL
      )
    ''');

    // Tabel untuk Foto Progres Perbaikan
    await db.execute('''
      CREATE TABLE perbaikan_foto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        perbaikan_id INTEGER NOT NULL,
        foto_path TEXT NOT NULL,
        deskripsi TEXT,
        progres INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (perbaikan_id) REFERENCES perbaikan (id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD Operations untuk Temuan
  Future<int> insertTemuan(Map<String, dynamic> temuan) async {
    final db = await database;
    return await db.insert('temuan', temuan);
  }

  Future<List<Map<String, dynamic>>> getTemuanByDate(String date) async {
    final db = await database;
    return await db.query(
      'temuan',
      where: 'created_date = ?',
      whereArgs: [date],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllTemuan() async {
    final db = await database;
    return await db.query('temuan', orderBy: 'timestamp DESC');
  }

  Future<int> deleteTemuan(int id) async {
    final db = await database;
    return await db.delete('temuan', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operations untuk Perbaikan
  Future<int> insertPerbaikan(Map<String, dynamic> perbaikan) async {
    final db = await database;
    return await db.insert('perbaikan', perbaikan);
  }

  Future<List<Map<String, dynamic>>> getAllPerbaikan() async {
    final db = await database;
    return await db.query('perbaikan', orderBy: 'updated_date DESC');
  }

  Future<Map<String, dynamic>?> getPerbaikanById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'perbaikan',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updatePerbaikan(int id, Map<String, dynamic> perbaikan) async {
    final db = await database;
    return await db.update(
      'perbaikan',
      perbaikan,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePerbaikan(int id) async {
    final db = await database;
    return await db.delete('perbaikan', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operations untuk Foto Perbaikan
  Future<int> insertPerbaikanFoto(Map<String, dynamic> foto) async {
    final db = await database;
    return await db.insert('perbaikan_foto', foto);
  }

  Future<List<Map<String, dynamic>>> getPerbaikanFotoByProject(int perbaikanId) async {
    final db = await database;
    return await db.query(
      'perbaikan_foto',
      where: 'perbaikan_id = ?',
      whereArgs: [perbaikanId],
      orderBy: 'progres ASC, timestamp ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getPerbaikanFotoByProgres(int perbaikanId, int progres) async {
    final db = await database;
    return await db.query(
      'perbaikan_foto',
      where: 'perbaikan_id = ? AND progres = ?',
      whereArgs: [perbaikanId, progres],
      orderBy: 'timestamp ASC',
    );
  }

  Future<int> deletePerbaikanFoto(int id) async {
    final db = await database;
    return await db.delete('perbaikan_foto', where: 'id = ?', whereArgs: [id]);
  }

  // Utility methods
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
