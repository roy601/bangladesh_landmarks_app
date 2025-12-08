import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/landmark_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('landmarks.db');
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
    await db.execute('''
      CREATE TABLE landmarks(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        image TEXT
      )
    ''');
  }

  /// Insert or update a landmark
  Future<void> insertLandmark(Landmark landmark) async {
    final db = await database;
    await db.insert(
      'landmarks',
      landmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple landmarks
  Future<void> insertLandmarks(List<Landmark> landmarks) async {
    final db = await database;
    final batch = db.batch();

    for (var landmark in landmarks) {
      batch.insert(
        'landmarks',
        landmark.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all landmarks
  Future<List<Landmark>> getLandmarks() async {
    final db = await database;
    final maps = await db.query('landmarks', orderBy: 'id DESC');

    return maps.map((map) => Landmark.fromMap(map)).toList();
  }

  /// Get a single landmark by id
  Future<Landmark?> getLandmark(int id) async {
    final db = await database;
    final maps = await db.query(
      'landmarks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Landmark.fromMap(maps.first);
    }
    return null;
  }

  /// Update a landmark
  Future<void> updateLandmark(Landmark landmark) async {
    final db = await database;
    await db.update(
      'landmarks',
      landmark.toMap(),
      where: 'id = ?',
      whereArgs: [landmark.id],
    );
  }

  /// Delete a landmark
  Future<void> deleteLandmark(int id) async {
    final db = await database;
    await db.delete(
      'landmarks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all landmarks
  Future<void> deleteAllLandmarks() async {
    final db = await database;
    await db.delete('landmarks');
  }

  /// Check if database is empty
  Future<bool> isEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM landmarks'),
    );
    return count == 0;
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
