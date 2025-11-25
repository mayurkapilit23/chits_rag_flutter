import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../widgets/otp_input_field.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  void handleOtpChange(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus(); // Move to next box
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus(); // Backspace → move back
    }
  }

  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Verify Phone",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Code is sent to 9944552288",
                style: TextStyle(fontSize: 15, color: Colors.black45),
              ),

              const SizedBox(height: 40),

              /// OTP Fields
              OtpInputField(
                controllers: controllers,
                onChanged: handleOtpChange,
              ),

              const SizedBox(height: 16),
              const Text(
                "Resend code in 00:17",
                style: TextStyle(color: Colors.grey),
              ),

              // const SizedBox(height: 5),
              // const Text("Get via call", style: TextStyle(color: Colors.blue)),
              const SizedBox(height: 30),
              Spacer(),

              /// Verify Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 55,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.black,
                    // gradient: const LinearGradient(
                    //   colors: [Color(0xff4F7DF3), Color(0xff335FE2)],
                    // ),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
