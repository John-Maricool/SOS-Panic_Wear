import 'package:hive/hive.dart';

import 'constants.dart';

class LocalStorage {
  static bool isFirstTime() {
    return Hive.box(local).get("isFirstTime", defaultValue: true);
  }

  static changeIsFirstTime(bool status) async {
    await Hive.box(local).put("isFirstTime", status);
  }

  static saveToken(String newToken) {
    Hive.box(token).put("token", newToken);
  }

  static String getToken() {
    return Hive.box(token).get("token", defaultValue: "");
  }

  static saveLat(num lat) {
    Hive.box(local).put("latitude", lat);
  }

  static num getLat() {
    return Hive.box(local).get("latitude", defaultValue: 0);
  }

  static saveLocAdd(String address) {
    Hive.box(local).put("address", address);
  }

  static String getLocAdd() {
    return Hive.box(local).get("address", defaultValue: "Enugu, Nigeria");
  }

  static saveLnt(num lat) {
    Hive.box(local).put("longitude", lat);
  }

  static num getLnt() {
    return Hive.box(local).get("longitude", defaultValue: 0);
  }
}
