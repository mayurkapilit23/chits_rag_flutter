import 'package:equatable/equatable.dart';

abstract class GptEvent extends Equatable {}

class SendPromptEvent extends GptEvent {
  final String prompt;
  final String mobile;
  final String sessionId;

  SendPromptEvent({
    required this.prompt,
    required this.mobile,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [prompt, mobile, sessionId];
}
