import 'auth_local_storage.dart';
import 'auth_services.dart';

class AuthRepo {
  final AuthServices api;
  final AuthLocalStorage storage;

  AuthRepo(this.api, this.storage);

  Future<void> sendOtp(String phone) {
    return api.sendOtp(phone);
  }

  Future<String> verifyOtp(String phone, String otp) async {
    final token = await api.verifyOtp(phone, otp);
    await storage.saveToken(token);
    return token;
  }

  Future<String?> getSavedToken() => storage.getToken();

  Future<void> logout() => storage.clearToken();
}
