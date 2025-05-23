import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:sos_wear_app/local_storage.dart';
import '../apis/report_api.dart';
import 'package:permission_handler/permission_handler.dart';
import '../random_functions.dart';

class UtilsController extends GetxController {
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxString address = "".obs;
  RxBool panicOn = false.obs;
  Timer? _locationUpdateTimer;
  int _panicId = 0;

  static const MethodChannel _locationChannel =
      MethodChannel('location_service');
  final Logger _logger = Logger();

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      // Check and request permission using permission_handler
      final permissionStatus = await Permission.location.request();

      if (!permissionStatus.isGranted) {
        _logger.w("Location permission denied");
        return;
      }

      // Get location directly without event stream
      final locationData = await _locationChannel
          .invokeMethod<Map<dynamic, dynamic>>('getCurrentLocation');

      if (locationData != null) {
        final latitude = locationData['latitude'] as double;
        final longitude = locationData['longitude'] as double;

        lat.value = latitude;
        lng.value = longitude;
        LocalStorage.saveLat(latitude);
        LocalStorage.saveLnt(longitude);

        _logger.d("Location updated - Lat: $latitude, Lng: $longitude");
      } else {
        _logger.w("Received null location data");
      }
    } on PlatformException catch (e) {
      _logger.e("Location error: ${e.message}");
    } catch (e) {
      _logger.e("Unexpected error getting location");
    }
  }

  Future<void> getFirstLocation() async {
    await getCurrentLocation();
  }

  void handlePanic() {
    panicOn.isTrue ? stopSendingPanic() : startSendingPanic();
  }

  void startSendingPanic() async {
    try {
      await getCurrentLocation();

      final response = await ReportApi().sendPanic(lat.value, lng.value);

      if (response != null) {
        _panicId = response["alert"]["id"];
        panicOn.value = true;
        RandomFunction.toast(ToastType.success, "Panic Started Successfully");

        _locationUpdateTimer =
            Timer.periodic(const Duration(seconds: 40), (timer) async {
          await getCurrentLocation();
          await ReportApi().updatePanic(lat.value, lng.value, _panicId);
        });
      }
    } catch (e) {
      _logger.e("Error starting panic");
      RandomFunction.toast(ToastType.error, "Failed to start panic");
    }
  }

  void stopSendingPanic() async {
    try {
      final response = await ReportApi().stopPanic();

      if (response != null) {
        _locationUpdateTimer?.cancel();
        _locationUpdateTimer = null;
        panicOn.value = false;
        RandomFunction.toast(ToastType.info, "Panic Stopped Successfully");
      }
    } catch (e) {
      _logger.e("Error stopping panic");
    }
  }

  Future<bool> requestPermission() async {
    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        getFirstLocation();
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    } catch (e) {
      _logger.e("Permission error");
      return false;
    }
  }
}
