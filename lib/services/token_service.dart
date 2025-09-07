import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  const TokenService({
    required this.secureStorage,
  });

  final FlutterSecureStorage secureStorage;

  // Namespaced key to avoid collisions
  static const String _accessTokenKey = 'rs_access_token';

  Future<String?> getToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<void> removeToken() async {
    await secureStorage.delete(key: _accessTokenKey);
  }
}
