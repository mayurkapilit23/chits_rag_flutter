import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class AuthServices {
  final baseUrl = "https://testapi.kapilchitskarnataka.com";

  Future<void> sendOtp(String phone) async {
    try {
      final url = Uri.parse("$baseUrl/api/SendloginOtp?Mobileno=$phone");

      log("url:$url");
      final res = await http.get(
        url,
        headers: {"content-type": "application/json"},
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> verifyOtp(String phone, String otp) async {
    final url = Uri.parse("$baseUrl/api/verifyotp?Mobileno=$phone&otp=$otp");
    final res = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode != 200) {
      throw Exception("OTP verification failed");
    }

    final data = jsonDecode(res.body);
    log("data:$data");

    return data['pToken']; // your backend response
  }
}
