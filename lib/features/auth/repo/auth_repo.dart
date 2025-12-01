import 'package:chatgpt_clone/features/auth/models/login_response_model.dart';

import 'auth_services.dart';

class AuthRepo {
  final AuthServices api;

  AuthRepo(this.api);

  Future<void> sendOtp(String phone) {
    return api.sendOtp(phone);
  }

  Future<LoginResponseModel> verifyOtp(String phone, String otp) async {
    final token = await api.verifyOtp(phone, otp);
    return token;
  }
}
