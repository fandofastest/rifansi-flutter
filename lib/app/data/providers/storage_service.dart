import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _lastUsernameKey = 'last_username';

  Future<StorageService> init() async {
    return this;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: userData.toString());
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userStr = await _storage.read(key: _userKey);
    if (userStr == null) return null;
    // TODO: Implement proper JSON parsing
    return {};
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> saveLastUsername(String username) async {
    await _storage.write(key: _lastUsernameKey, value: username);
  }

  Future<String?> getLastUsername() async {
    return await _storage.read(key: _lastUsernameKey);
  }
} 