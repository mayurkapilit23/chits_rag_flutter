import 'package:chatgpt_clone/features/gpt/repo/gpt_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/models/session_manager.dart';
import '../model/conversation.dart';
import '../model/message.dart';
import 'gpt_event.dart';
import 'gpt_state.dart';

class GptBloc extends Bloc<GptEvent, GptState> {
  final GptRepo repo;

  GptBloc(this.repo) : super(GptInitialState()) {
    on<LoadInitialDataEvent>(_onLoadInitial);
    on<SendUserMessageEvent>(_onSendMessage);
    on<CreateConversationEvent>(_onCreateConversation);
    on<SelectConversationEvent>(_onSelectConversation);
    on<DeleteConversationEvent>(_onDeleteConversation);
  }

  //select conversation
  void _onSelectConversation(
    SelectConversationEvent event,
    Emitter<GptState> emit,
  ) {
    if (state is! GptLoadedState) return;

    final current = state as GptLoadedState;

    emit(current.copyWith(selectedConversationIndex: event.index));
  }

  //load initial data
  Future<void> _onLoadInitial(
    LoadInitialDataEvent event,
    Emitter<GptState> emit,
  ) async {
    try {
      final login = await SessionManager.isLoggedIn();
      final model = await SessionManager.getUser();

      // Default conversation
      final conversations = [
        Conversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: "New Chat",
          messages: [],
        ),
      ];

      emit(
        GptLoadedState(
          conversations: conversations,
          selectedConversationIndex: 0,
          isTyping: false,
          isLoggedIn: login,
          mobileNumber: model?.pmobileno,
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  //send message to server

  Future<void> _onSendMessage(
    SendUserMessageEvent event,
    Emitter<GptState> emit,
  ) async {
    if (state is! GptLoadedState) return;
    final current = state as GptLoadedState;
    final conversations = List<Conversation>.from(current.conversations);
    final conversation = conversations[current.selectedConversationIndex];

    // Add user message
    final userMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.prompt,
      time: DateTime.now(),
      isUser: true,
    );
    conversation.messages.add(userMsg);

    // conversation.messages.add(
    //   Message(
    //     id: DateTime.now().millisecondsSinceEpoch.toString(),
    //     text: event.prompt,
    //     time: DateTime.now(),
    //     isUser: true,
    //   ),
    // );
    print('From Bloc');
    print('user prompt:${event.prompt}');
    print('user mobile:${event.mobile}');
    print('user mobile:${event.sessionId}');

    // If first message → update conversation title
    if (conversation.messages.length == 1) {
      final newTitle = event.prompt.length > 30
          ? "${event.prompt.substring(0, 30)}..."
          : event.prompt;

      conversations[current.selectedConversationIndex] = conversation.copyWith(
        title: newTitle,
      );
    }

    emit(
      GptMessageSendingState(
        conversations: conversations,
        selectedConversationIndex: current.selectedConversationIndex,
        isTyping: true,
        isLoggedIn: current.isLoggedIn,
        mobileNumber: current.mobileNumber,
      ),
    );

    // Simulate API call / GPT response
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final replyText = await repo.sendMessage(
        prompt: event.prompt,
        mobile: event.mobile,
        sessionId: event.sessionId,
      );

      print("GPT API Reply: $replyText");

      // final botResponseText = replyText ?? replyText.toString();

      final botMsg = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: replyText,
        time: DateTime.now(),
        isUser: false,
      );
      conversation.messages.add(botMsg);

      emit(
        GptLoadedState(
          conversations: conversations,
          selectedConversationIndex: current.selectedConversationIndex,
          isTyping: false,
          isLoggedIn: current.isLoggedIn,
          mobileNumber: current.mobileNumber,
        ),
      );
    } catch (e) {
      print("BLoC ERROR: $e");

      emit(GptErrorState(e.toString()));
    }
  }

  // create new conversation
  void _onCreateConversation(
    CreateConversationEvent event,
    Emitter<GptState> emit,
  ) {
    if (state is! GptLoadedState) return;

    final current = state as GptLoadedState;

    final newConv = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      // id: "conv_${current.conversations.length}",
      title: "New chat",
      // title: "Conversation ${current.conversations.length + 1}",
      messages: [],
    );

    final updated = [newConv, ...current.conversations];

    emit(
      current.copyWith(
        conversations: updated,
        selectedConversationIndex: 0,
        isTyping: false,
      ),
    );
  }

  //delete conversation
  void _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<GptState> emit,
  ) {
    if (state is! GptLoadedState) return;

    final current = state as GptLoadedState;

    if (current.conversations.length <= 1) return;

    final updated = List<Conversation>.from(current.conversations)
      ..removeAt(event.index);

    emit(
      current.copyWith(conversations: updated, selectedConversationIndex: 0),
    );
  }
}
