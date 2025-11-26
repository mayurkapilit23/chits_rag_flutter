import 'package:equatable/equatable.dart';

abstract class GptState extends Equatable {}

class GptInitial extends GptState {
  @override
  List<Object?> get props => [];
}

class GptLoading extends GptState {
  @override
  List<Object?> get props => [];
}

class GptSuccess extends GptState {
  final String reply;

  GptSuccess(this.reply);

  @override
  List<Object?> get props => [reply];
}

class GptError extends GptState {
  final String message;

  GptError(this.message);

  @override
  List<Object?> get props => [message];
}
