import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;

  Conversation({required this.id, required this.title, required this.messages});

  Conversation copyWith({String? id, String? title, List<Message>? messages}) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }
}
