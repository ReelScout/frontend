import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  const TokenService({
    required this.secureStorage,
  });

  final FlutterSecureStorage secureStorage;

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'accessToken');
  }

  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'accessToken', value: token);
  }

  Future<void> removeToken() async {
    await secureStorage.delete(key: 'accessToken');
  }
}