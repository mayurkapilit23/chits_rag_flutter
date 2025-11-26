import 'package:chatgpt_clone/features/gpt/repo/gpt_services.dart';

class GptRepo {
  final GptServices api;

  GptRepo(this.api);

  Future<String> sendMessage({
    required String prompt,
    required String mobile,
    required String sessionId,
  }) {
    return api.sendMessage(
      prompt: prompt,
      mobile: mobile,
      sessionId: sessionId,
    );
  }
}
