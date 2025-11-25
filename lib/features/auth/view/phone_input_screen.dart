import 'package:chatgpt_clone/features/auth/view/verify_phone_number_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';

class InputPhoneNumberScreen extends StatefulWidget {
  const InputPhoneNumberScreen({super.key});

  @override
  State<InputPhoneNumberScreen> createState() => _InputPhoneNumberScreenState();
}

class _InputPhoneNumberScreenState extends State<InputPhoneNumberScreen> {
  TextEditingController controller = TextEditingController();
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
                "Mobile Number",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your will receive a 4 digit code to verify next.",
                style: TextStyle(fontSize: 15, color: Colors.black45),
              ),

              const SizedBox(height: 40),

              TextField(
                onChanged: (sfs) {
                  setState(() {});
                },
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hint: Text('Enter Phone Number'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // const SizedBox(height: 5),
              // const Text("Get via call", style: TextStyle(color: Colors.blue)),
              const SizedBox(height: 30),
              Spacer(),

              /// Verify Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VerifyPhoneScreen()),
                  );
                },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: controller.text.length == 10
                        ? Colors.black
                        : Colors.grey,
                    // gradient: const LinearGradient(
                    //   colors: [Color(0xff4F7DF3), Color(0xff335FE2)],
                    // ),
                  ),
                  child: const Text(
                    "Continue",
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
