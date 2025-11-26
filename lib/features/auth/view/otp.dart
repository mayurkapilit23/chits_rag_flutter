import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

void showOtpSheet(BuildContext context, String phoneNumber) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => OtpVerificationSheet(phoneNumber: phoneNumber),
  );
}

class OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationSheet({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isValid = false;
  int timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNodes.first.requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    timerSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds == 0) {
        timer.cancel();
      }
      setState(() {
        timerSeconds--;
      });
    });
  }

  void _validateOtp() {
    final otp = _controllers.map((c) => c.text).join();
    setState(() {
      isValid = otp.length == 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.40,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthenticatedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mobile Number se login hogya')),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    Text(
                      "Verify OTP",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter the 6-digit code sent to +91 ${widget.phoneNumber}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 25),

                    // OTP input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48,
                          height: 58,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                              _validateOtp();
                            },
                          ),
                        );
                      }),
                    ),

                    ConstSized(25),

                    // Resend timer
                    Center(
                      child: TextButton(
                        onPressed: timerSeconds == 0
                            ? () {
                                _startTimer();
                                // resend API here
                              }
                            : null,
                        child: Text(
                          timerSeconds == 0
                              ? "Resend OTP"
                              : "Resend in $timerSeconds sec",
                          style: TextStyle(
                            color: timerSeconds == 0
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValid
                              ? Colors.black
                              : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isValid
                            ? () {
                                final otp = _controllers
                                    .map((c) => c.text)
                                    .join();

                                // Verify OTP API here
                                context.read<AuthBloc>().add(
                                  VerifyOtpEvent(widget.phoneNumber, otp),
                                );

                                Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (state is AuthLoading) CircularProgressIndicator(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ConstSized extends SizedBox {
  const ConstSized(double h, {super.key}) : super(height: h);
}
