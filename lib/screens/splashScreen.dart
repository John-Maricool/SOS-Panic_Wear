import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sos_wear_app/controllers/UtilsController.dart';
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
    Get.find<UtilsController>().requestPermission().then((v) {
      if (v) {
        Future.delayed(Duration(seconds: 2), () {
          if (LocalStorage.getToken().isEmpty) {
            Get.off(ExistingUser());
          } else {
            Get.off(PulsingPanicButton());
          }
        });
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
