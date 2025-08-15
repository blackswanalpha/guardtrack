import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart' as app_exceptions;
import '../models/user_model.dart';
import '../models/site_model.dart';
import '../models/attendance_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, AppConstants.databaseName);

      return await openDatabase(
        dbPath,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to initialize database');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Drop and recreate tables for now
      await _dropTables(db);
      await _createTables(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        role TEXT NOT NULL,
        profile_image_url TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        assigned_site_ids TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Sites table
    await db.execute('''
      CREATE TABLE sites (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        allowed_radius REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        description TEXT,
        contact_person TEXT,
        contact_phone TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        assigned_guard_ids TEXT,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        guard_id TEXT NOT NULL,
        site_id TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        arrival_code TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        photo_url TEXT,
        notes TEXT,
        admin_notes TEXT,
        verified_by TEXT,
        verified_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (guard_id) REFERENCES users (id),
        FOREIGN KEY (site_id) REFERENCES sites (id)
      )
    ''');

    // Sync queue table for offline operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Check-in events table for daily reporting
    await db.execute('''
      CREATE TABLE check_in_events (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        site_id TEXT NOT NULL,
        site_name TEXT NOT NULL,
        check_in_time INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        arrival_code TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
        'CREATE INDEX idx_attendance_guard_id ON attendance (guard_id)');
    await db
        .execute('CREATE INDEX idx_attendance_site_id ON attendance (site_id)');
    await db.execute(
        'CREATE INDEX idx_attendance_timestamp ON attendance (timestamp)');
    await db
        .execute('CREATE INDEX idx_attendance_status ON attendance (status)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_table ON sync_queue (table_name)');
    await db.execute(
        'CREATE INDEX idx_check_in_events_employee ON check_in_events (employee_id)');
    await db.execute(
        'CREATE INDEX idx_check_in_events_site ON check_in_events (site_id)');
    await db.execute(
        'CREATE INDEX idx_check_in_events_time ON check_in_events (check_in_time)');
  }

  Future<void> _dropTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS check_in_events');
    await db.execute('DROP TABLE IF EXISTS sync_queue');
    await db.execute('DROP TABLE IF EXISTS attendance');
    await db.execute('DROP TABLE IF EXISTS sites');
    await db.execute('DROP TABLE IF EXISTS users');
  }

  // User operations
  Future<void> insertUser(UserModel user) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        _userToMap(user),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to insert user');
    }
  }

  Future<UserModel?> getUser(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _mapToUser(maps.first);
      }
      return null;
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get user');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final db = await database;
      await db.update(
        'users',
        _userToMap(user),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to update user');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final db = await database;
      final maps = await db.query('users');
      return maps.map((map) => _mapToUser(map)).toList();
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get users');
    }
  }

  // Site operations
  Future<void> insertSite(SiteModel site) async {
    try {
      final db = await database;
      await db.insert(
        'sites',
        _siteToMap(site),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to insert site');
    }
  }

  Future<List<SiteModel>> getSites() async {
    try {
      final db = await database;
      final maps = await db.query('sites', orderBy: 'name ASC');
      return maps.map((map) => _mapToSite(map)).toList();
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get sites');
    }
  }

  Future<SiteModel?> getSite(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'sites',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _mapToSite(maps.first);
      }
      return null;
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get site');
    }
  }

  Future<List<SiteModel>> getSitesForGuard(String guardId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'sites',
        where: 'assigned_guard_ids LIKE ?',
        whereArgs: ['%$guardId%'],
        orderBy: 'name ASC',
      );
      return maps.map((map) => _mapToSite(map)).toList();
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get sites for guard');
    }
  }

  // Attendance operations
  Future<void> insertAttendance(AttendanceModel attendance) async {
    try {
      final db = await database;
      await db.insert(
        'attendance',
        _attendanceToMap(attendance),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to insert attendance');
    }
  }

  Future<List<AttendanceModel>> getAttendanceForGuard(
    String guardId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        'attendance',
        where: 'guard_id = ?',
        whereArgs: [guardId],
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => _mapToAttendance(map)).toList();
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get attendance');
    }
  }

  Future<List<AttendanceModel>> getAttendanceInDateRange(
    String guardId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final maps = await db.query(
        'attendance',
        where: 'guard_id = ? AND timestamp BETWEEN ? AND ?',
        whereArgs: [
          guardId,
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => _mapToAttendance(map)).toList();
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get attendance in date range');
    }
  }

  Future<AttendanceModel?> getLatestAttendanceForSite(
      String guardId, String siteId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'attendance',
        where: 'guard_id = ? AND site_id = ?',
        whereArgs: [guardId, siteId],
        orderBy: 'timestamp DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return _mapToAttendance(maps.first);
      }
      return null;
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get latest attendance');
    }
  }

  // Sync operations
  Future<void> addToSyncQueue(String tableName, String recordId,
      String operation, Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.insert('sync_queue', {
        'table_name': tableName,
        'record_id': recordId,
        'operation': operation,
        'data': data.toString(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
      });
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to add to sync queue');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    try {
      final db = await database;
      return await db.query(
        'sync_queue',
        orderBy: 'created_at ASC',
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get pending sync items');
    }
  }

  Future<void> removeSyncItem(int id) async {
    try {
      final db = await database;
      await db.delete(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to remove sync item');
    }
  }

  // Utility methods for data conversion
  Map<String, dynamic> _userToMap(UserModel user) {
    return {
      'id': user.id,
      'email': user.email,
      'phone': user.phone,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'role': user.role.name,
      'profile_image_url': user.profileImageUrl,
      'is_active': user.isActive ? 1 : 0,
      'created_at': user.createdAt.millisecondsSinceEpoch,
      'updated_at': user.updatedAt?.millisecondsSinceEpoch,
      'assigned_site_ids': user.assignedSiteIds?.join(','),
      'synced': 1,
    };
  }

  UserModel _mapToUser(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      phone: map['phone'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      profileImageUrl: map['profile_image_url'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
      assignedSiteIds: map['assigned_site_ids']?.split(','),
    );
  }

  Map<String, dynamic> _siteToMap(SiteModel site) {
    return {
      'id': site.id,
      'name': site.name,
      'address': site.address,
      'latitude': site.latitude,
      'longitude': site.longitude,
      'allowed_radius': site.allowedRadius,
      'is_active': site.isActive ? 1 : 0,
      'description': site.description,
      'contact_person': site.contactPerson,
      'contact_phone': site.contactPhone,
      'created_at': site.createdAt.millisecondsSinceEpoch,
      'updated_at': site.updatedAt?.millisecondsSinceEpoch,
      'assigned_guard_ids': site.assignedGuardIds?.join(','),
      'synced': 1,
    };
  }

  SiteModel _mapToSite(Map<String, dynamic> map) {
    return SiteModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      allowedRadius: map['allowed_radius'],
      isActive: map['is_active'] == 1,
      description: map['description'],
      contactPerson: map['contact_person'],
      contactPhone: map['contact_phone'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
      assignedGuardIds: map['assigned_guard_ids']?.split(','),
    );
  }

  Map<String, dynamic> _attendanceToMap(AttendanceModel attendance) {
    return {
      'id': attendance.id,
      'guard_id': attendance.guardId,
      'site_id': attendance.siteId,
      'type': attendance.type.name,
      'status': attendance.status.name,
      'arrival_code': attendance.arrivalCode,
      'latitude': attendance.latitude,
      'longitude': attendance.longitude,
      'accuracy': attendance.accuracy,
      'timestamp': attendance.timestamp.millisecondsSinceEpoch,
      'photo_url': attendance.photoUrl,
      'notes': attendance.notes,
      'admin_notes': attendance.adminNotes,
      'verified_by': attendance.verifiedBy,
      'verified_at': attendance.verifiedAt?.millisecondsSinceEpoch,
      'created_at': attendance.createdAt.millisecondsSinceEpoch,
      'updated_at': attendance.updatedAt?.millisecondsSinceEpoch,
      'synced': 0, // New attendance records start as unsynced
    };
  }

  AttendanceModel _mapToAttendance(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      guardId: map['guard_id'],
      siteId: map['site_id'],
      type: AttendanceType.values.firstWhere((e) => e.name == map['type']),
      status:
          AttendanceStatus.values.firstWhere((e) => e.name == map['status']),
      arrivalCode: map['arrival_code'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      accuracy: map['accuracy'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      photoUrl: map['photo_url'],
      notes: map['notes'],
      adminNotes: map['admin_notes'],
      verifiedBy: map['verified_by'],
      verifiedAt: map['verified_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['verified_at'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : null,
    );
  }

  // Check-in events operations
  Future<void> insertCheckInEvent(Map<String, dynamic> event) async {
    try {
      final db = await database;
      await db.insert(
        'check_in_events',
        event,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to insert check-in event');
    }
  }

  Future<List<Map<String, dynamic>>> getCheckInEventsForDateRange(
      int startTime, int endTime) async {
    try {
      final db = await database;
      return await db.query(
        'check_in_events',
        where: 'check_in_time >= ? AND check_in_time <= ?',
        whereArgs: [startTime, endTime],
        orderBy: 'check_in_time ASC',
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get check-in events for date range');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCheckInEvents() async {
    try {
      final db = await database;
      return await db.query(
        'check_in_events',
        orderBy: 'check_in_time DESC',
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to get all check-in events');
    }
  }

  Future<void> deleteOldCheckInEvents(int olderThanTimestamp) async {
    try {
      final db = await database;
      await db.delete(
        'check_in_events',
        where: 'created_at < ?',
        whereArgs: [olderThanTimestamp],
      );
    } catch (e) {
      throw const app_exceptions.DatabaseException(
          message: 'Failed to delete old check-in events');
    }
  }

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
