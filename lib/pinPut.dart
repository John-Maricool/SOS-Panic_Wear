import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import 'colors.dart';

class PinField extends StatelessWidget {
  const PinField({super.key, required this.otpController});

  final TextEditingController otpController;
  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 5,
      controller: otpController,
      focusedPinTheme: PinTheme(
          height: 45,
          width: 40,
          decoration: BoxDecoration(
              border: Border.all(color: AppColor.green),
              borderRadius: BorderRadius.circular(10))),
    );
  }
}
