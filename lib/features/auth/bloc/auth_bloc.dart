import 'package:chatgpt_clone/features/auth/repo/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/session_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthStatusEvent>(_onCheckStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repo.sendOtp(event.phone);
      emit(OtpSentState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await repo.verifyOtp(event.phone, event.otp);
      emit(AuthenticatedState(token));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onCheckStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final loginResponseModel = await SessionManager.getUser();
    final token = loginResponseModel?.pToken;

    if (token != null && token.isNotEmpty) {
      emit(AuthenticatedState(loginResponseModel!)); // user logged in
    } else {
      emit(UnauthenticatedState()); // user logged out
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await SessionManager.logout();
    emit(UnauthenticatedState());
  }
}
