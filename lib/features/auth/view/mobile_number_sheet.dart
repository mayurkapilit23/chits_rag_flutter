import 'package:chatgpt_clone/core/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'otp_verification_sheet.dart';

void showMobileNumberSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context), // close on outside tap
        child: GestureDetector(
          onTap: () {}, // prevent closing on inside tap
          child: const MobileNumberSheet(),
        ),
      );
    },
  );
}

class MobileNumberSheet extends StatefulWidget {
  const MobileNumberSheet({super.key});

  @override
  State<MobileNumberSheet> createState() => _MobileNumberSheetState();
}

class _MobileNumberSheetState extends State<MobileNumberSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),

          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSecondary : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Form(
              key: _formKey,
              onChanged: () {
                setState(() {
                  isValid = _formKey.currentState!.validate();
                });
              },
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is OtpSentState) {
                    // return showOtpSheet(context, _phoneController.text);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('otps sent')));
                  }
                  if (state is AuthErrorState) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
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
                          "Enter Mobile Number",
                          style: TextStyle(
                            color: isDark
                                ? AppColors.whiteColor
                                : AppColors.darkPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "We will send an OTP to verify your number.",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 25),

                        // PHONE FIELD
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          autofocus: true,

                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black, // 👈 focus border color
                                width: 1.2,
                              ),
                            ),
                            counterText: "",
                            labelText: "Mobile Number",
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            prefixText: "+91 ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Mobile number is required";
                            }
                            if (value.length != 10) {
                              return "Enter a valid 10-digit number";
                            }
                            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                              return "Enter a valid Indian mobile number";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 25),

                        // SUBMIT BUTTON
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
                                    context.read<AuthBloc>().add(
                                      SendOtpEvent(
                                        _phoneController.text.trim(),
                                      ),
                                    );
                                    Navigator.pop(context);
                                    showOtpSheet(
                                      context,
                                      _phoneController.text,
                                    );
                                  }
                                : null,
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (state is AuthLoading)
                          Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
