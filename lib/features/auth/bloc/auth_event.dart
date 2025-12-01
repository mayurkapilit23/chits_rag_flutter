import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {}

class SendOtpEvent extends AuthEvent {
  final String phone;
  SendOtpEvent(this.phone);
  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  VerifyOtpEvent(this.phone, this.otp);
  @override
  List<Object?> get props => [phone, otp];
}
