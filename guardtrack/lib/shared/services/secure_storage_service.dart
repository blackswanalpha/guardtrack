import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token Management
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      throw StorageException(message: 'Failed to save token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      throw StorageException(message: 'Failed to get token: $e');
    }
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw StorageException(message: 'Failed to save refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw StorageException(message: 'Failed to get refresh token: $e');
    }
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _storage.write(key: AppConstants.userKey, value: jsonString);
    } catch (e) {
      throw StorageException(message: 'Failed to save user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = await _storage.read(key: AppConstants.userKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw StorageException(message: 'Failed to get user data: $e');
    }
  }

  // Generic Storage Methods
  Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException(message: 'Failed to save string: $e');
    }
  }

  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException(message: 'Failed to get string: $e');
    }
  }

  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      await _storage.write(key: key, value: jsonString);
    } catch (e) {
      throw StorageException(message: 'Failed to save JSON: $e');
    }
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final jsonString = await _storage.read(key: key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw StorageException(message: 'Failed to get JSON: $e');
    }
  }

  // Clear Methods
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
    } catch (e) {
      throw StorageException(message: 'Failed to clear token: $e');
    }
  }

  Future<void> clearRefreshToken() async {
    try {
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw StorageException(message: 'Failed to clear refresh token: $e');
    }
  }

  Future<void> clearUserData() async {
    try {
      await _storage.delete(key: AppConstants.userKey);
    } catch (e) {
      throw StorageException(message: 'Failed to clear user data: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException(message: 'Failed to clear all data: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException(message: 'Failed to delete key: $e');
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw StorageException(message: 'Failed to check key existence: $e');
    }
  }
}
