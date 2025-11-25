// login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is OtpSentState) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpPage(phone: phoneController.text),
                  ),
                );
              }
              if (state is AuthErrorState) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.shade100,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Mobile No.',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        keyboardType: TextInputType.number,
                        controller: phoneController,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          SendOtpEvent(phoneController.text),
                        );
                      },
                      child: Text("Send OTP"),
                    ),
                    if (state is AuthLoading) CircularProgressIndicator(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
