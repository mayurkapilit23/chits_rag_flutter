import 'package:chatgpt_clone/features/auth/models/login_response_model.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class OtpSentState extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthenticatedState extends AuthState {
  final LoginResponseModel model;

  AuthenticatedState(this.model);

  @override
  List<Object?> get props => [model];
}

class UnauthenticatedState extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
