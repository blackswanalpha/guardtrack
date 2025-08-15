import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/errors/exceptions.dart';
import 'api_service.dart';
import 'database_service.dart';
import '../models/attendance_model.dart';
import '../models/site_model.dart';
import '../models/user_model.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  final Connectivity _connectivity = Connectivity();

  StreamController<SyncStatus>? _syncStatusController;
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;

  // Get sync status stream
  Stream<SyncStatus> get syncStatusStream {
    _syncStatusController ??= StreamController<SyncStatus>.broadcast();
    return _syncStatusController!.stream;
  }

  // Start periodic sync
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(interval, (_) {
      syncAll();
    });
  }

  // Stop periodic sync
  void stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  // Check network connectivity
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Sync all pending data
  Future<void> syncAll() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      _emitSyncStatus(SyncStatus.syncing);

      if (!await isConnected()) {
        throw NetworkException(message: 'No internet connection');
      }

      // Sync pending attendance records
      await _syncPendingAttendance();

      // Sync user data
      await _syncUserData();

      // Sync sites data
      await _syncSitesData();

      _emitSyncStatus(SyncStatus.success);
    } catch (e) {
      _emitSyncStatus(SyncStatus.error);
      throw NetworkException(message: 'Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Sync pending attendance records
  Future<void> _syncPendingAttendance() async {
    try {
      final pendingItems = await _databaseService.getPendingSyncItems();
      
      for (final item in pendingItems) {
        if (item['table_name'] == 'attendance') {
          try {
            final data = jsonDecode(item['data']) as Map<String, dynamic>;
            
            switch (item['operation']) {
              case 'INSERT':
                await _apiService.post('/attendance', data: data);
                break;
              case 'UPDATE':
                await _apiService.put('/attendance/${item['record_id']}', data: data);
                break;
              case 'DELETE':
                await _apiService.delete('/attendance/${item['record_id']}');
                break;
            }
            
            // Remove from sync queue on success
            await _databaseService.removeSyncItem(item['id']);
          } catch (e) {
            // Log error but continue with other items
            print('Failed to sync attendance item ${item['id']}: $e');
          }
        }
      }
    } catch (e) {
      throw NetworkException(message: 'Failed to sync attendance: $e');
    }
  }

  // Sync user data from server
  Future<void> _syncUserData() async {
    try {
      final response = await _apiService.get('/user/profile');
      final user = UserModel.fromJson(response['data']);
      await _databaseService.insertUser(user);
    } catch (e) {
      // User data sync is not critical, log and continue
      print('Failed to sync user data: $e');
    }
  }

  // Sync sites data from server
  Future<void> _syncSitesData() async {
    try {
      final response = await _apiService.get('/sites/assigned');
      final sitesData = response['data'] as List<dynamic>;
      
      for (final siteData in sitesData) {
        final site = SiteModel.fromJson(siteData);
        await _databaseService.insertSite(site);
      }
    } catch (e) {
      // Sites data sync is not critical, log and continue
      print('Failed to sync sites data: $e');
    }
  }

  // Save attendance for offline sync
  Future<void> saveAttendanceForSync(AttendanceModel attendance) async {
    try {
      // Save to local database
      await _databaseService.insertAttendance(attendance);
      
      // Add to sync queue
      await _databaseService.addToSyncQueue(
        'attendance',
        attendance.id,
        'INSERT',
        attendance.toJson(),
      );

      // Try immediate sync if connected
      if (await isConnected()) {
        try {
          await _syncPendingAttendance();
        } catch (e) {
          // Sync will be retried later
          print('Immediate sync failed: $e');
        }
      }
    } catch (e) {
      throw StorageException(message: 'Failed to save attendance for sync: $e');
    }
  }

  // Update attendance for offline sync
  Future<void> updateAttendanceForSync(AttendanceModel attendance) async {
    try {
      // Update in local database
      await _databaseService.insertAttendance(attendance); // Using insert with replace
      
      // Add to sync queue
      await _databaseService.addToSyncQueue(
        'attendance',
        attendance.id,
        'UPDATE',
        attendance.toJson(),
      );

      // Try immediate sync if connected
      if (await isConnected()) {
        try {
          await _syncPendingAttendance();
        } catch (e) {
          // Sync will be retried later
          print('Immediate sync failed: $e');
        }
      }
    } catch (e) {
      throw StorageException(message: 'Failed to update attendance for sync: $e');
    }
  }

  // Force sync now
  Future<void> forceSyncNow() async {
    await syncAll();
  }

  // Get sync statistics
  Future<SyncStatistics> getSyncStatistics() async {
    try {
      final pendingItems = await _databaseService.getPendingSyncItems();
      final isConnected = await this.isConnected();
      
      return SyncStatistics(
        pendingItems: pendingItems.length,
        isConnected: isConnected,
        isSyncing: _isSyncing,
        lastSyncAttempt: DateTime.now(), // TODO: Store actual last sync time
      );
    } catch (e) {
      throw StorageException(message: 'Failed to get sync statistics: $e');
    }
  }

  void _emitSyncStatus(SyncStatus status) {
    _syncStatusController?.add(status);
  }

  // Dispose resources
  void dispose() {
    stopPeriodicSync();
    _syncStatusController?.close();
    _syncStatusController = null;
  }
}

class SyncStatistics {
  final int pendingItems;
  final bool isConnected;
  final bool isSyncing;
  final DateTime lastSyncAttempt;

  const SyncStatistics({
    required this.pendingItems,
    required this.isConnected,
    required this.isSyncing,
    required this.lastSyncAttempt,
  });
}
