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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Verify OTP',
                style: AppTextTheme.h14
                    .copyWith(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(
                height: 10,
              ),
              Text.rich(
                TextSpan(
                  text:
                      "Enter the 5-digit code that was sent to your phone number ",
                  style: AppTextTheme.h11,
                  children: [
                    TextSpan(
                        text: "$phone",
                        style: AppTextTheme.h11.copyWith(
                            color: AppColor.green,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                  child: PinField(
                otpController: otpController,
              )),
              const SizedBox(
                height: 10,
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
                      style: AppTextTheme.h11.copyWith(color: AppColor.green),
                    ),
                  ),
                  Text(
                    '${count}s',
                    style: AppTextTheme.h11,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Obx(() => NavContainerButton(
                    text: 'Signin',
                    appState: controller.appState.value,
                    isEnabled: true,
                    width: 100,
                    height: 35,
                    onTap: () {
                      if (otpController.text.isEmpty) {
                        RandomFunction.toast(
                            ToastType.info, "Please input a phone number");
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
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
