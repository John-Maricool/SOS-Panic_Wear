import 'package:get/get.dart';

import '../apis/login_api.dart';
import '../app_state.dart';

class LoginController extends GetxController {
  Rx<AppState> appState = AppState.idle.obs;

  Future<bool> requestOtp(String phone) async {
    appState.value = AppState.busy;
    final res = await LoginApi().requestOtp(phone);
    appState.value = AppState.idle;
    if (res != null) {
      return true;
    }
    return false;
  }

  Future<bool> login(String phone, String otp) async {
    appState.value = AppState.busy;
    final res = await LoginApi().login(phone, otp);
    appState.value = AppState.idle;
    if (res != null) {
      return true;
    }
    return false;
  }
}
