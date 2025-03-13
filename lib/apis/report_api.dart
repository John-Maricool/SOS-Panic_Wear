import 'dart:async';

import 'package:http/http.dart' as http;

import '../../request.dart';

class ReportApi {
  var client = http.Client();

  Future<Map<String, dynamic>?> sendPanic(
      double latitude, double longitude) async {
    try {
      var data = await postRequest(client, "panic-alerts",
          {"latitude": latitude, "longitude": longitude}, true);
      if (data != null) {}
      return data;
    } catch (e) {}
    return null;
  }
}
