import 'dart:async';

import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../apis/report_api.dart';
import 'package:permission_handler/permission_handler.dart';

import '../random_functions.dart';

class UtilsController extends GetxController {
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxString address = "".obs;
  RxBool panicOn = false.obs;
  Timer? _timer = null;

  @override
  void onInit() async {
    super.onInit();
    requestPermission();
  }

  handlePanic() {
    panicOn.isTrue ? startSendingPanic() : startSendingPanic();
  }

  startSendingPanic() async {
    await ReportApi().sendPanic(lat.value, lng.value).then((v) {
      if (v != null) {
        panicOn.value = true;
        RandomFunction.toast(
            ToastType.success, "Panic Has Started Successfully");
        _timer = Timer.periodic(Duration(seconds: 2), (v) async {
          await ReportApi().sendPanic(lat.value, lng.value);
        });
      }
    });
  }

  stopSendingPanic() async {
    panicOn.value = false;
    _timer!.cancel();
    _timer = null;
    RandomFunction.toast(ToastType.info, "Panic Has Ended Successfully");
  }

  getDeviceLocation() async {
    try {
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      var placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      print(placemarks.first.country);
      print(placemarks.first.administrativeArea);
      print(placemarks.first.subLocality);
      address.value =
          "${placemarks.first.subLocality} ${placemarks.first.administrativeArea ?? ""},  ${placemarks.first.country ?? ""}";
      lat.value = position.latitude;
      lng.value = position.longitude;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> requestPermission() async {
    const permission = Permission.location;

    while (true) {
      if (await permission.isGranted) {
        getDeviceLocation();
        return true;
      } else if (await permission.isPermanentlyDenied) {
        return false;
      } else {
        final result = await permission.request();
        if (result.isGranted) {
          getDeviceLocation();
          return true;
        } else if (result.isPermanentlyDenied) {
          return false;
        }
      }
    }
  }
}
