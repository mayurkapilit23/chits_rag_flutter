import 'package:chatgpt_clone/features/gpt/repo/gpt_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'gpt_event.dart';
import 'gpt_state.dart';

class GptBloc extends Bloc<GptEvent, GptState> {
  final GptRepo repo;

  GptBloc(this.repo) : super(GptInitial()) {
    on<SendPromptEvent>(_onSendPrompt);
  }

  Future<void> _onSendPrompt(
    SendPromptEvent event,
    Emitter<GptState> emit,
  ) async {
    emit(GptLoading());
    try {
      final reply = await repo.sendMessage(
        prompt: event.prompt,
        mobile: event.mobile,
        sessionId: event.sessionId,
      );
      emit(GptSuccess(reply));
    } catch (e) {
      emit(GptError(e.toString()));
    }
  }
}
