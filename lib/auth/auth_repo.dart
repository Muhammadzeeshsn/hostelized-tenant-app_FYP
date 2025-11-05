import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'mock_users.dart';

class AuthRepo {
  AuthRepo(this._storage);
  final FlutterSecureStorage _storage;

  Future<bool> signInLocal(String u, String p) async =>
      mockUsers.any((e) => e.username == u && e.password == p);

  Future<bool> verifyOtpLocal(String otp) async => otp.trim() == '123456';

  Future<void> persistSession() async {
    await _storage.write(key: 'accessToken', value: 'local_fake_access');
    await _storage.write(key: 'refreshToken', value: 'local_fake_refresh');
  }
}
