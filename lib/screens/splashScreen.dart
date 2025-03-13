import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sos_wear_app/screens/existing_User.dart';
import 'package:sos_wear_app/screens/pulsing_panic_button.dart';
import '../local_storage.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      if (LocalStorage.getToken().isEmpty) {
        Get.to(ExistingUser());
      } else {
        Get.to(PulsingPanicButton());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/splash-screen.png'),
                fit: BoxFit.cover)),
      ),
    );
  }
}
