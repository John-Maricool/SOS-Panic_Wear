import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sos_wear_app/screens/pulsing_panic_button.dart';

import '../app_text_theme.dart';
import '../colors.dart';
import '../controllers/login_controller.dart';
import '../nav_container.dart';
import '../pinPut.dart';
import '../random_functions.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key});

  @override
  State<LoginOtp> createState() => _SigninOTPScreenState();
}

class _SigninOTPScreenState extends State<LoginOtp> {
  LoginController controller = Get.put(LoginController());
  TextEditingController otpController = TextEditingController();
  final phone = Get.arguments;

  @override
  void initState() {
    countDown();
    super.initState();
  }

  int count = 60;

  Timer? timer;
  void countDown() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (count > 0) {
        setState(() {
          count--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify OTP',
                style: AppTextTheme.h18
                    .copyWith(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Text.rich(
                TextSpan(
                  text:
                      "Enter the 4-digit code that was sent to your phone number ",
                  style: AppTextTheme.h14,
                  children: [
                    TextSpan(
                        text: "$phone", // The phone number
                        style: AppTextTheme.h14.copyWith(
                            color: AppColor.green,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: PinField(
                otpController: otpController,
              )),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        count = 60;
                        countDown();
                      });
                    },
                    child: Text(
                      'Resend code in ',
                      style: AppTextTheme.h14.copyWith(color: AppColor.green),
                    ),
                  ),
                  Text(
                    '${count}s',
                    style: AppTextTheme.h14,
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height / 4,
              ),
              Obx(() => NavContainerButton(
                    text: 'Signin',
                    appState: controller.appState.value,
                    isEnabled: true,
                    onTap: () {
                      if (otpController.text.isEmpty) {
                        RandomFunction.toast(
                            ToastType.info, "Please input a phone number");
                        return;
                      }
                      if (count == 0) {
                        RandomFunction.toast(ToastType.info,
                            "Click on Resend code for new  OTP");
                        return;
                      } else {
                        controller
                            .login(phone, otpController.text.trim())
                            .then((res) {
                          if (res) {
                            Future.delayed(Duration(milliseconds: 500), () {
                              RandomFunction.toast(
                                  ToastType.success, "Login Successful!");
                            });

                            Get.offAll(PulsingPanicButton());
                          }
                        });
                      }
                      // Get.off(() => const HomeBottomNav());
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
