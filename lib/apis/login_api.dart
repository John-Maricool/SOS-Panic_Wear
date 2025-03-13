import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../local_storage.dart';
import '../request.dart';

class LoginApi {
  var client = http.Client();

  Future<Map<String, dynamic>?> login(String phone, String otp) async {
    try {
      var data = await postRequest(
          client, "login", {"phone": phone, "otp": otp}, false);
      Logger().e(data);
      if (data != null) {
        LocalStorage.saveToken(data["token"]);
      }
      return data;
    } catch (e) {
      Logger().e(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> requestOtp(String phone) async {
    try {
      var data =
          await postRequest(client, "request-otp", {"phone": phone}, false);
      Logger().e(data);
      if (data != null) {}
      return data;
    } catch (e) {
      Logger().e(e.toString());
    }
    return null;
  }
}
