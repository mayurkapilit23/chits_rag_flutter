import 'package:equatable/equatable.dart';

import '../model/conversation.dart';

abstract class GptState extends Equatable {}

class GptInitialState extends GptState {
  @override
  List<Object?> get props => [];
}

class GptLoadingState extends GptState {
  @override
  List<Object?> get props => [];
}

class GptLoadedState extends GptState {
  final List<Conversation> conversations;
  final int selectedConversationIndex;
  final bool isTyping;
  final bool isLoggedIn;
  final String? mobileNumber;

  GptLoadedState({
    required this.conversations,
    required this.selectedConversationIndex,
    required this.isTyping,
    required this.isLoggedIn,
    required this.mobileNumber,
  });

  GptLoadedState copyWith({
    List<Conversation>? conversations,
    int? selectedConversationIndex,
    bool? isTyping,
    bool? isLoggedIn,
    String? mobileNumber,
  }) {
    return GptLoadedState(
      conversations: conversations ?? this.conversations,
      selectedConversationIndex:
          selectedConversationIndex ?? this.selectedConversationIndex,
      isTyping: isTyping ?? this.isTyping,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    selectedConversationIndex,
    isTyping,
    isLoggedIn,
    mobileNumber,
  ];
}

class GptMessageSendingState extends GptLoadedState {
  GptMessageSendingState({
    required super.conversations,
    required super.selectedConversationIndex,
    required super.isTyping,
    required super.isLoggedIn,
    required super.mobileNumber,
  });
}

class GptErrorState extends GptState {
  final String message;

  GptErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
