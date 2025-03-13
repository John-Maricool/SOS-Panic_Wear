import 'package:flutter/material.dart';

import 'colors.dart';

class AppTextTheme {
  static String family = "Inter";
  static TextStyle h28 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: AppColor.black,
    fontFamily: family,
  );

  static TextStyle h18 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColor.black,
    fontFamily: family,
  );
  static TextStyle h16 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColor.black,
    fontFamily: family,
  );
  static TextStyle h14 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColor.black,
    fontFamily: family,
  );
  static TextStyle h12 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColor.black,
    fontFamily: family,
  );
  static TextStyle h11 = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 11,
    color: AppColor.black,
    fontFamily: family,
  );
  static TextStyle hint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColor.black,
    fontFamily: family,
  );
}
