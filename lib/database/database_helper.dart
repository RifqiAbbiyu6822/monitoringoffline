import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../models/perbaikan_progress.dart';

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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
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

      // Tabel Perbaikan Progress
      await db.execute('''
        CREATE TABLE perbaikan_progress(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          perbaikan_id INTEGER NOT NULL,
          tanggal INTEGER NOT NULL,
          status_progress TEXT NOT NULL,
          deskripsi_progress TEXT NOT NULL,
          foto_path TEXT,
          latitude TEXT NOT NULL,
          longitude TEXT NOT NULL,
          FOREIGN KEY (perbaikan_id) REFERENCES perbaikan (id) ON DELETE CASCADE
        )
      ''');

      // Tambahkan index untuk performa query yang lebih baik
      await db.execute('CREATE INDEX idx_temuan_tanggal ON temuan(tanggal)');
      await db.execute('CREATE INDEX idx_temuan_jalur ON temuan(jalur)');
      await db.execute('CREATE INDEX idx_perbaikan_tanggal ON perbaikan(tanggal)');
      await db.execute('CREATE INDEX idx_perbaikan_jalur ON perbaikan(jalur)');
      await db.execute('CREATE INDEX idx_perbaikan_status ON perbaikan(status_perbaikan)');
      await db.execute('CREATE INDEX idx_perbaikan_progress_perbaikan_id ON perbaikan_progress(perbaikan_id)');
      await db.execute('CREATE INDEX idx_perbaikan_progress_tanggal ON perbaikan_progress(tanggal)');
    } catch (e) {
      throw Exception('Gagal membuat database: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        // Tambahkan kolom kilometer, latitude, dan longitude ke tabel temuan
        await db.execute('ALTER TABLE temuan ADD COLUMN kilometer TEXT');
        await db.execute('ALTER TABLE temuan ADD COLUMN latitude TEXT');
        await db.execute('ALTER TABLE temuan ADD COLUMN longitude TEXT');
        
        // Tambahkan kolom kilometer, latitude, dan longitude ke tabel perbaikan
        await db.execute('ALTER TABLE perbaikan ADD COLUMN kilometer TEXT');
        await db.execute('ALTER TABLE perbaikan ADD COLUMN latitude TEXT');
        await db.execute('ALTER TABLE perbaikan ADD COLUMN longitude TEXT');
        
        // Tambahkan index untuk kolom baru
        await db.execute('CREATE INDEX idx_temuan_tanggal ON temuan(tanggal)');
        await db.execute('CREATE INDEX idx_temuan_jalur ON temuan(jalur)');
        await db.execute('CREATE INDEX idx_perbaikan_tanggal ON perbaikan(tanggal)');
        await db.execute('CREATE INDEX idx_perbaikan_jalur ON perbaikan(jalur)');
        await db.execute('CREATE INDEX idx_perbaikan_status ON perbaikan(status_perbaikan)');
      }
      
      if (oldVersion < 3) {
        // Tambahkan tabel perbaikan_progress
        await db.execute('''
          CREATE TABLE perbaikan_progress(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            perbaikan_id INTEGER NOT NULL,
            tanggal INTEGER NOT NULL,
            status_progress TEXT NOT NULL,
            deskripsi_progress TEXT NOT NULL,
            foto_path TEXT,
            latitude TEXT NOT NULL,
            longitude TEXT NOT NULL,
            FOREIGN KEY (perbaikan_id) REFERENCES perbaikan (id) ON DELETE CASCADE
          )
        ''');
        
        // Tambahkan index untuk tabel perbaikan_progress
        await db.execute('CREATE INDEX idx_perbaikan_progress_perbaikan_id ON perbaikan_progress(perbaikan_id)');
        await db.execute('CREATE INDEX idx_perbaikan_progress_tanggal ON perbaikan_progress(tanggal)');
      }
    } catch (e) {
      throw Exception('Gagal mengupgrade database: $e');
    }
  }

  // CRUD Operations untuk Temuan
  Future<int> insertTemuan(Temuan temuan) async {
    try {
      final db = await database;
      return await db.insert('temuan', temuan.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan data temuan: $e');
    }
  }

  Future<List<Temuan>> getAllTemuan() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'temuan',
        orderBy: 'tanggal DESC',
      );
      return List.generate(maps.length, (i) => Temuan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data temuan: $e');
    }
  }

  Future<List<Temuan>> getTemuanByDate(DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final List<Map<String, dynamic>> maps = await db.query(
        'temuan',
        where: 'tanggal >= ? AND tanggal <= ?',
        whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
        orderBy: 'tanggal DESC',
      );
      return List.generate(maps.length, (i) => Temuan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data temuan berdasarkan tanggal: $e');
    }
  }

  Future<int> updateTemuan(Temuan temuan) async {
    try {
      final db = await database;
      return await db.update(
        'temuan',
        temuan.toMap(),
        where: 'id = ?',
        whereArgs: [temuan.id],
      );
    } catch (e) {
      throw Exception('Gagal mengupdate data temuan: $e');
    }
  }

  Future<int> deleteTemuan(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'temuan',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data temuan: $e');
    }
  }

  // CRUD Operations untuk Perbaikan
  Future<int> insertPerbaikan(Perbaikan perbaikan) async {
    try {
      final db = await database;
      return await db.insert('perbaikan', perbaikan.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan data perbaikan: $e');
    }
  }

  Future<List<Perbaikan>> getAllPerbaikan() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'perbaikan',
        orderBy: 'tanggal DESC',
      );
      return List.generate(maps.length, (i) => Perbaikan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data perbaikan: $e');
    }
  }

  Future<List<Perbaikan>> getPerbaikanByDate(DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final List<Map<String, dynamic>> maps = await db.query(
        'perbaikan',
        where: 'tanggal >= ? AND tanggal <= ?',
        whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
        orderBy: 'tanggal DESC',
      );
      return List.generate(maps.length, (i) => Perbaikan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data perbaikan berdasarkan tanggal: $e');
    }
  }

  Future<int> updatePerbaikan(Perbaikan perbaikan) async {
    try {
      final db = await database;
      return await db.update(
        'perbaikan',
        perbaikan.toMap(),
        where: 'id = ?',
        whereArgs: [perbaikan.id],
      );
    } catch (e) {
      throw Exception('Gagal mengupdate data perbaikan: $e');
    }
  }

  Future<int> deletePerbaikan(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'perbaikan',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data perbaikan: $e');
    }
  }

  // Advanced query methods untuk search dan filter
  Future<List<Temuan>> searchTemuan({
    String? searchQuery,
    String? jalur,
    String? lajur,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? orderBy,
    bool ascending = false,
  }) async {
    try {
      final db = await database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      // Build where clause
      List<String> conditions = [];
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        conditions.add('(jenis_temuan LIKE ? OR deskripsi LIKE ? OR jalur LIKE ? OR lajur LIKE ? OR kilometer LIKE ?)');
        final searchPattern = '%$searchQuery%';
        whereArgs.addAll([searchPattern, searchPattern, searchPattern, searchPattern, searchPattern]);
      }
      
      if (jalur != null && jalur.isNotEmpty && jalur != 'Semua') {
        conditions.add('jalur = ?');
        whereArgs.add(jalur);
      }
      
      if (lajur != null && lajur.isNotEmpty && lajur != 'Semua') {
        conditions.add('lajur = ?');
        whereArgs.add(lajur);
      }
      
      if (dateFrom != null) {
        conditions.add('tanggal >= ?');
        whereArgs.add(dateFrom.millisecondsSinceEpoch);
      }
      
      if (dateTo != null) {
        conditions.add('tanggal <= ?');
        whereArgs.add(dateTo.millisecondsSinceEpoch);
      }
      
      if (conditions.isNotEmpty) {
        whereClause = 'WHERE ${conditions.join(' AND ')}';
      }
      
      // Build order by clause
      String orderByClause = '';
      if (orderBy != null && orderBy.isNotEmpty) {
        orderByClause = 'ORDER BY $orderBy ${ascending ? 'ASC' : 'DESC'}';
      } else {
        orderByClause = 'ORDER BY tanggal DESC';
      }
      
      final query = 'SELECT * FROM temuan $whereClause $orderByClause';
      final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);
      
      return List.generate(maps.length, (i) => Temuan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mencari data temuan: $e');
    }
  }

  Future<List<Perbaikan>> searchPerbaikan({
    String? searchQuery,
    String? jalur,
    String? lajur,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? orderBy,
    bool ascending = false,
  }) async {
    try {
      final db = await database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      // Build where clause
      List<String> conditions = [];
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        conditions.add('(jenis_perbaikan LIKE ? OR deskripsi LIKE ? OR jalur LIKE ? OR lajur LIKE ? OR kilometer LIKE ? OR status_perbaikan LIKE ?)');
        final searchPattern = '%$searchQuery%';
        whereArgs.addAll([searchPattern, searchPattern, searchPattern, searchPattern, searchPattern, searchPattern]);
      }
      
      if (jalur != null && jalur.isNotEmpty && jalur != 'Semua') {
        conditions.add('jalur = ?');
        whereArgs.add(jalur);
      }
      
      if (lajur != null && lajur.isNotEmpty && lajur != 'Semua') {
        conditions.add('lajur = ?');
        whereArgs.add(lajur);
      }
      
      if (dateFrom != null) {
        conditions.add('tanggal >= ?');
        whereArgs.add(dateFrom.millisecondsSinceEpoch);
      }
      
      if (dateTo != null) {
        conditions.add('tanggal <= ?');
        whereArgs.add(dateTo.millisecondsSinceEpoch);
      }
      
      if (conditions.isNotEmpty) {
        whereClause = 'WHERE ${conditions.join(' AND ')}';
      }
      
      // Build order by clause
      String orderByClause = '';
      if (orderBy != null && orderBy.isNotEmpty) {
        orderByClause = 'ORDER BY $orderBy ${ascending ? 'ASC' : 'DESC'}';
      } else {
        orderByClause = 'ORDER BY tanggal DESC';
      }
      
      final query = 'SELECT * FROM perbaikan $whereClause $orderByClause';
      final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);
      
      return List.generate(maps.length, (i) => Perbaikan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mencari data perbaikan: $e');
    }
  }

  // Get statistics
  Future<Map<String, int>> getTemuanStatistics() async {
    try {
      final db = await database;
      
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM temuan');
      final total = totalResult.first['count'] as int;
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final todayResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM temuan WHERE tanggal >= ? AND tanggal <= ?',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      );
      final todayCount = todayResult.first['count'] as int;
      
      return {
        'total': total,
        'today': todayCount,
      };
    } catch (e) {
      throw Exception('Gagal mendapatkan statistik temuan: $e');
    }
  }

  Future<Map<String, int>> getPerbaikanStatistics() async {
    try {
      final db = await database;
      
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM perbaikan');
      final total = totalResult.first['count'] as int;
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final todayResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM perbaikan WHERE tanggal >= ? AND tanggal <= ?',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      );
      final todayCount = todayResult.first['count'] as int;
      
      return {
        'total': total,
        'today': todayCount,
      };
    } catch (e) {
      throw Exception('Gagal mendapatkan statistik perbaikan: $e');
    }
  }

  // Get data by date range
  Future<List<Temuan>> getTemuanByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final db = await database;
      final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      final List<Map<String, dynamic>> maps = await db.query(
        'temuan',
        where: 'tanggal >= ? AND tanggal <= ?',
        whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
        orderBy: 'tanggal DESC',
      );
      return List.generate(maps.length, (i) => Temuan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data temuan berdasarkan range tanggal: $e');
    }
  }

  Future<List<Perbaikan>> getPerbaikanByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final db = await database;
      final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      
      final List<Map<String, dynamic>> maps = await db.query(
        'perbaikan',
        where: 'tanggal >= ? AND tanggal <= ?',
        whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
        orderBy: 'tanggal DESC',
      );
      return List.generate(maps.length, (i) => Perbaikan.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil data perbaikan berdasarkan range tanggal: $e');
    }
  }

  // CRUD Operations untuk Perbaikan Progress
  Future<int> insertPerbaikanProgress(PerbaikanProgress progress) async {
    try {
      final db = await database;
      return await db.insert('perbaikan_progress', progress.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan progress perbaikan: $e');
    }
  }

  Future<List<PerbaikanProgress>> getPerbaikanProgressByPerbaikanId(int perbaikanId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'perbaikan_progress',
        where: 'perbaikan_id = ?',
        whereArgs: [perbaikanId],
        orderBy: 'tanggal ASC',
      );
      return List.generate(maps.length, (i) => PerbaikanProgress.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Gagal mengambil progress perbaikan: $e');
    }
  }

  Future<PerbaikanProgress?> getPerbaikanProgressById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'perbaikan_progress',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return PerbaikanProgress.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil progress perbaikan: $e');
    }
  }

  Future<int> updatePerbaikanProgress(PerbaikanProgress progress) async {
    try {
      final db = await database;
      return await db.update(
        'perbaikan_progress',
        progress.toMap(),
        where: 'id = ?',
        whereArgs: [progress.id],
      );
    } catch (e) {
      throw Exception('Gagal memperbarui progress perbaikan: $e');
    }
  }

  Future<int> deletePerbaikanProgress(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'perbaikan_progress',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus progress perbaikan: $e');
    }
  }

  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
    } catch (e) {
      throw Exception('Gagal menutup database: $e');
    }
  }
}
