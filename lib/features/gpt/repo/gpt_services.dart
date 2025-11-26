import 'dart:convert';

import 'package:http/http.dart' as http;

class GptServices {
  final baseUrl = "https://your-backend.com/api/chat";

  Future<String> sendMessage({
    required String prompt,
    required String mobile,
    required String sessionId,
  }) async {
    final url = Uri.parse(baseUrl);

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "prompt": prompt,
        "mobile": mobile,
        "session_id": sessionId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to send message");
    }

    final data = jsonDecode(res.body);
    return data["response"] ?? "No response from server";
  }
}
