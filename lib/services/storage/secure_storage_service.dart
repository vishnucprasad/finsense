import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const _apiKeyKey = 'gemini_api_key';

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKeyKey, value: key);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }
}

@riverpod
SecureStorageService secureStorage(SecureStorageRef ref) {
  return SecureStorageService(const FlutterSecureStorage());
}
