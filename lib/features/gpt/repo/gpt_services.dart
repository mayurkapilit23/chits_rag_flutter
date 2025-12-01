import 'dart:convert';

import 'package:chatgpt_clone/features/auth/models/session_manager.dart';
import 'package:http/http.dart' as http;

class GptServices {
  final baseUrl = "http://192.168.15.168:9000/api/ask-natasha";

  Future<String> sendMessage({
    required String prompt,
    required String mobile,
    required String sessionId,
  }) async {
    final url = Uri.parse(baseUrl);
    final user = await SessionManager.getUser();

    try {
      print("🔵 API CALL → $baseUrl");
      print("🔵 Session-ID: $sessionId");
      print("🔵 Token: ${user?.pToken}");
      print(
        "🔵 Sending body: ${jsonEncode({"message": prompt, "mobile": mobile})}",
      );
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${user?.pToken}",
          "Session-ID": sessionId,
        },
        body: jsonEncode({"message": prompt, "mobile": mobile}),
      );

      print("🟡 STATUS: ${res.statusCode}");
      print("🟡 RAW BODY: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("HTTP ERROR ${res.statusCode}: ${res.body}");
      }
      //
      // if (res.statusCode != 200) {
      //   throw Exception("Failed to send message");
      // }

      final data = jsonDecode(res.body);
      print('services: ${data}');
      // print('services: message ${data['message']}');
      // print('services: ans ${data['answer']}');

      // PRIMARY KEY
      if (data["answer"] != null) {
        return data["answer"].toString();
      }

      // FALLBACK KEYS
      if (data["message"] != null) {
        return data["message"].toString();
      }
      return "No valid answer from server";

      // return data["response"]?.toString() ?? "No response from server";
    } catch (e) {
      print('services : ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}
