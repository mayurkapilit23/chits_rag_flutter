import 'package:equatable/equatable.dart';

abstract class GptEvent extends Equatable {}

class LoadInitialDataEvent extends GptEvent {
  @override
  List<Object?> get props => [];
}

class SendUserMessageEvent extends GptEvent {
  final String prompt;
  final String mobile;
  final String? sessionId;

  SendUserMessageEvent({
    required this.prompt,
    required this.mobile,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [prompt, mobile, sessionId];
}

class CreateConversationEvent extends GptEvent {
  @override
  List<Object?> get props => [];
}

class SelectConversationEvent extends GptEvent {
  final int index;

  SelectConversationEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class DeleteConversationEvent extends GptEvent {
  final int index;

  DeleteConversationEvent(this.index);

  @override
  List<Object?> get props => [index];
}
