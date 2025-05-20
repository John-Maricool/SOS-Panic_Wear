import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:sos_wear_app/screens/pulsing_panic_button.dart';
import 'package:sos_wear_app/screens/splashScreen.dart';
import 'bindings/initial_binding.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory tempDir = await getApplicationDocumentsDirectory();

  Hive.init(tempDir.path);
  await Hive.openBox(local);
  await Hive.openBox(token);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      builder: (context, child) => GetMaterialApp(
          title: "SOS Panic",
          debugShowCheckedModeBanner: false,
          builder: BotToastInit(),
          defaultTransition: Transition.fadeIn,
          initialBinding: InitialBinding(),
          home: Splashscreen()),
      designSize: const Size(240, 240),
    );
  }
}
