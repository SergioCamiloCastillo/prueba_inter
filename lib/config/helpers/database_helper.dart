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
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            latitude REAL,
            longitude REAL,
            description TEXT,
            location TEXT,
            UNIQUE(name, latitude, longitude)
          )
        ''');

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

        await db.execute('''
          CREATE TABLE friend_locations(
            friendId INTEGER,
            locationId INTEGER,
            PRIMARY KEY (friendId, locationId),
            FOREIGN KEY (friendId) REFERENCES friends(id) ON DELETE CASCADE,
            FOREIGN KEY (locationId) REFERENCES locations(id) ON DELETE CASCADE
          )
        ''');

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
}
