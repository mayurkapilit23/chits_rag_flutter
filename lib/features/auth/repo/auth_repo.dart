import 'auth_local_storage.dart';
import 'auth_services.dart';

class AuthRepo {
  late final AuthServices api;
  late final AuthLocalStorage storage;

  AuthRepo({required this.api, required this.storage});

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
