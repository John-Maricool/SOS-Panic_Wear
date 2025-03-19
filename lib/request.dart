import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;

import 'failure.dart';
import 'local_storage.dart';

var baseurl = "https://app.resqcloud.online/api/";

Future<Map<String, dynamic>?> postRequest(
  http.Client client,
  String endpoint,
  dynamic body,
  bool parseToken,
) async {
  var token = LocalStorage.getToken();

  try {
    Future.delayed(Duration(seconds: 10));
    final response = await client
        .post(
          Uri.parse("$baseurl$endpoint"),
          body: jsonEncode(body),
          headers: parseToken == true
              ? {
                  "Content-Type": "application/json",
                  "Accept": "application/json",
                  "Authorization": "Bearer $token"
                }
              : {
                  "Content-Type": "application/json",
                  "Accept": "application/json",
                },
        )
        .timeout(const Duration(seconds: 60));

    final data = jsonDecode(response.body);
    bool status = data["success"] ?? false;

    if (data["status"] != null &&
            (data["status"] as String).toLowerCase() == "success" ||
        status == true) {
      return data;
    } else {
      throw Failure(data["message"] ?? "");
    }
  } on SocketException catch (_) {
    throw Failure("No internet connection");
  } on HttpException catch (_) {
    throw Failure("Service not currently available");
  } on TimeoutException catch (_) {
    throw Failure("Poor internet connection");
  } catch (e) {
    print(e.toString());
    throw Failure(e.toString());
  }
  return null;
}
