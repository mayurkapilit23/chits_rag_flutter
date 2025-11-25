// otp_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  const OtpPage({required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthenticatedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mobile Number se login hogya')),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade100,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'otp',
                        contentPadding: EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.number,
                      controller: otpController,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        VerifyOtpEvent(widget.phone, otpController.text),
                      );
                    },
                    child: Text("Verify OTP"),
                  ),
                  if (state is AuthLoading) CircularProgressIndicator(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
