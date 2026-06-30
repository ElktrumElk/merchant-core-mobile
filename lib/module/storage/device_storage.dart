import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceStorage {

  // Encapsulated secure hardware storage instance for iOS/Android
  static final _storage = FlutterSecureStorage();
  static String _tokenKey = '';


  /// Saves the token securely to the device hardware keychain system
  static Future<void> saveValue(String value) async {
    await _storage.write(key: _tokenKey, value: value);
  }

  /// Reads the encrypted token value back out from hardware storage
  static Future<String?> loadValue(String key) async {
    return await _storage.read(key: key);
  }

  /// Wipes out the current active session token storage data (Log out)
  static Future<void> deleteValue() async {
    await _storage.delete(key: _tokenKey);
  }

   static void setKey (String key) {
    _tokenKey = key;
  }
}