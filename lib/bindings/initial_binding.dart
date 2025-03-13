import 'package:get/get.dart';

import '../controllers/UtilsController.dart';

class InitialBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    Get.put(UtilsController(), permanent: true);
  }
}
