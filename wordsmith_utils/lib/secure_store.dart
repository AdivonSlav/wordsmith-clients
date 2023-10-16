import "package:flutter_secure_storage/flutter_secure_storage.dart";

abstract class SecureStore {
  static const _storage = FlutterSecureStorage();

  static Future<String?> getValue(String key) async {
    return await _storage.read(key: key);
  }

  static Future deleteValue(String key) async {
    await _storage.delete(key: key);
  }

  static Future writeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
}
