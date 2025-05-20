import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../request.dart';
import '../random_functions.dart';

class ReportApi {
  var client = http.Client();

  Future<Map<String, dynamic>?> stopPanic() async {
    try {
      var data = await postRequest(client, "panic-alerts/resolve", null, true);
      Logger().e(data);
      if (data != null) {}
      return data;
    } catch (e) {
      RandomFunction.toast(ToastType.error, e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> sendPanic(
      double latitude, double longitude) async {
    try {
      var data = await postRequest(client, "panic-alerts",
          {"latitude": latitude, "longitude": longitude}, true);
      Logger().e(data);
      if (data != null) {}
      return data;
    } catch (e) {
      Logger().e(e.toString());
      RandomFunction.toast(ToastType.error, e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>?> updatePanic(
      double latitude, double longitude, int id) async {
    try {
      var data = await postRequest(client, "panic-alerts/$id",
          {"latitude": latitude, "longitude": longitude}, true);
      Logger().e(data);
      if (data != null) {}
      return data;
    } catch (e) {
      RandomFunction.toast(ToastType.error, e.toString());
    }
    return null;
  }
}
