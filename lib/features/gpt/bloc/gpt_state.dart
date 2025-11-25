import 'package:equatable/equatable.dart';

abstract class GptState extends Equatable {}

class GptInitialState extends GptState {
  @override
  List<Object?> get props => [];
}
