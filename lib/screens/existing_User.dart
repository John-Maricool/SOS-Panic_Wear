import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sos_wear_app/screens/login_Otp.dart';

import '../app_text_theme.dart';
import '../colors.dart';
import '../controllers/login_controller.dart';
import '../nav_container.dart';
import '../random_functions.dart';

class ExistingUser extends StatelessWidget {
  ExistingUser({super.key});

  final LoginController controller = Get.put(LoginController());
  final TextEditingController phonecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SingleChildScrollView(
        // Make the content scrollable
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05, // Adjust padding dynamically
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              IntlPhoneField(
                cursorColor: AppColor.green,
                disableLengthCheck: true,
                initialCountryCode: 'NG',
                controller: phonecontroller,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(
                      10), // Limit to 10 characters
                ],
                flagsButtonMargin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02, // Adjust margin dynamically
                  vertical: screenHeight * 0.01,
                ),
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter your phone number',
                  hintStyle: AppTextTheme.h12.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColor.green,
                      width: 2, // Blue border when focused
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownDecoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey, // Divider color
                      width: 1, // Divider thickness
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: screenHeight * 0.03), // Adjust spacing dynamically
              Obx(
                () => NavContainerButton(
                  text: 'Signin',
                  isEnabled: true,
                  appState: controller.appState.value,
                  onTap: () {
                    if (phonecontroller.text.isEmpty) {
                      RandomFunction.toast(
                        ToastType.info,
                        "Please input a phone number",
                      );
                      return;
                    } else {
                      controller
                          .requestOtp("0${phonecontroller.text}")
                          .then((result) {
                        if (result == true) {
                          Future.delayed(Duration(milliseconds: 500), () {
                            RandomFunction.toast(
                              ToastType.success,
                              "Otp sent to your phone number",
                            );
                          });
                          Get.to(LoginOtp(), arguments: phonecontroller.text);
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
