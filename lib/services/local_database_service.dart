import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/attendance_event_model.dart';

class LocalDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'rebs_hrms.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attendance_events (
            eventId TEXT PRIMARY KEY,
            type TEXT,
            occurredAt TEXT,
            latitude REAL,
            longitude REAL,
            status TEXT,
            rejectionReason TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  Future<void> saveEvent(AttendanceEventModel event) async {
    final db = await database;

    await db.insert(
      'attendance_events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<AttendanceEventModel>> getEvents() async {
    final db = await database;

    final result = await db.query(
      'attendance_events',
      orderBy: 'occurredAt ASC',
    );

    return result.map(AttendanceEventModel.fromJson).toList();
  }

  Future<List<AttendanceEventModel>> getPendingEvents() async {
    final db = await database;

    final result = await db.query(
      'attendance_events',
      where: 'status = ?',
      whereArgs: ['Pending Sync'],
      orderBy: 'occurredAt ASC',
    );

    return result.map(AttendanceEventModel.fromJson).toList();
  }

  Future<void> updateEvent(AttendanceEventModel event) async {
    final db = await database;

    await db.update(
      'attendance_events',
      event.toJson(),
      where: 'eventId = ?',
      whereArgs: [event.eventId],
    );
  }
}
