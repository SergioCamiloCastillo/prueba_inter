import 'dart:convert'; // Para usar jsonEncode
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    //await deleteDatabase(join(await getDatabasesPath(), 'app_database.db'));

    return await openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      version: 1,
      onCreate: (db, version) async {
        // Crear la tabla de locations
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            latitude REAL,
            longitude REAL,
            description TEXT
          )
        ''');

        // Crear la tabla de friends
        await db.execute('''
          CREATE TABLE friends(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT,
            lastName TEXT,
            email TEXT,
            phoneNumber TEXT,
            photoUrl TEXT
          )
        ''');

        // Crear la tabla intermedia friend_locations
        await db.execute('''
          CREATE TABLE friend_locations(
            friendId INTEGER,
            locationId INTEGER,
            PRIMARY KEY (friendId, locationId),
            FOREIGN KEY (friendId) REFERENCES friends(id) ON DELETE CASCADE,
            FOREIGN KEY (locationId) REFERENCES locations(id) ON DELETE CASCADE
          )
        ''');

        // Crear la tabla de fotos
        await db.execute('''
          CREATE TABLE photos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            locationId INTEGER,
            url TEXT,
            FOREIGN KEY (locationId) REFERENCES locations(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Método para agregar una ubicación
  Future<void> insertLocation(String name, String description, double latitude,
      double longitude, List<String> photos) async {
    final db = await database;

    // Convertir fotos a JSON
    String photosJson = jsonEncode(photos);

    await db.insert('locations', {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photosJson,
    });
  }

  // Método para obtener todas las ubicaciones
  Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await database;
    return await db.query('locations');
  }

  // Método para eliminar una ubicación
  Future<void> deleteLocation(int id) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  // Método para agregar fotos a una ubicación
  Future<void> insertPhoto(int locationId, String url) async {
    final db = await database;
    await db.insert('photos', {
      'locationId': locationId,
      'url': url,
    });
  }

  // Método para obtener fotos de una ubicación
  Future<List<Map<String, dynamic>>> getPhotos(int locationId) async {
    final db = await database;
    return await db
        .query('photos', where: 'locationId = ?', whereArgs: [locationId]);
  }

  // Método para eliminar fotos de una ubicación
  Future<void> deletePhoto(int id) async {
    final db = await database;
    await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }
}
