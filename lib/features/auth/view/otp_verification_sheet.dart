import 'package:chatgpt_clone/features/auth/models/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../core/colors/app_colors.dart';
import '../../gpt/bloc/gpt_bloc.dart';
import '../../gpt/bloc/gpt_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

void showOtpSheet(BuildContext context, String phoneNumber) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context), // close on outside tap
      child: Container(child: OtpVerificationSheet(phoneNumber: phoneNumber)),
    ),
  );
}

class OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationSheet({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  bool isValid = false;
  String _otpValue = "";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.40,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthenticatedState) {
              SessionManager.saveUser(state.model);
              context.read<GptBloc>().add(LoadInitialDataEvent());
              Navigator.of(context).maybePop(); // close all bottom sheets
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Login successful")));
            }
          },
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSecondary : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
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
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.darkPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter the 6-digit code sent to +91 ${widget.phoneNumber}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 25),

                    state is AuthLoading
                        ? Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              // OTP input fields
                              Pinput(
                                length: 6,
                                defaultPinTheme: PinTheme(
                                  width: 48,
                                  height: 58,
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                focusedPinTheme: PinTheme(
                                  width: 48,
                                  height: 58,
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black),
                                  ),
                                ),
                                onChanged: (value) {
                                  _otpValue = value;
                                  setState(() {
                                    isValid = value.length == 6;
                                  });
                                },
                                onCompleted: (value) {
                                  _otpValue = value;
                                  setState(() {
                                    isValid = true;
                                  });
                                },
                              ),

                              SizedBox(height: 40),

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
                                          // Verify OTP API here
                                          context.read<AuthBloc>().add(
                                            VerifyOtpEvent(
                                              widget.phoneNumber,
                                              _otpValue,
                                            ),
                                          );
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
                            ],
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
