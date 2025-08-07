import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'attendkal.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  // Tables
  static const String usersTable = 'users';
  static const String coursesTable = 'courses';
  static const String attendanceTable = 'attendance';
  static const String subscriptionTable = 'subscription';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $usersTable (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Courses table
    await db.execute('''
      CREATE TABLE $coursesTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        instructor TEXT NOT NULL,
        schedule TEXT NOT NULL,
        color TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE $attendanceTable (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (course_id) REFERENCES $coursesTable (id) ON DELETE CASCADE
      )
    ''');

    // Subscription table
    await db.execute('''
      CREATE TABLE $subscriptionTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_courses_user_id ON $coursesTable(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_attendance_course_id ON $attendanceTable(course_id)',
    );
    await db.execute(
      'CREATE INDEX idx_attendance_date ON $attendanceTable(date)',
    );
    await db.execute(
      'CREATE INDEX idx_subscription_user_id ON $subscriptionTable(user_id)',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add migration logic for version 2
    }
  }

  // Generic insert method
  static Future<int> insert(String table, Map<String, dynamic> values) async {
    Database db = await database;
    return db.insert(table, values);
  }

  // Generic query method
  static Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    Database db = await database;
    return db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  // Generic update method
  static Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    Database db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  // Generic delete method
  static Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    Database db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(attendanceTable);
    await db.delete(coursesTable);
    await db.delete(subscriptionTable);
    await db.delete(usersTable);
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
