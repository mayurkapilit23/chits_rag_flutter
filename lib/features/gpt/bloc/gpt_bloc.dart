import 'package:flutter_bloc/flutter_bloc.dart';

import 'gpt_event.dart';
import 'gpt_state.dart';

class GptBloc extends Bloc<GptEvent, GptState> {
  GptBloc() : super(GptInitialState()) {
    on<GptEvent>((event, emit) {});
  }
}
