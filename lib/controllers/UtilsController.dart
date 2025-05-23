// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'package:sos_wear_app/local_storage.dart';
// import '../apis/report_api.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../random_functions.dart';
//
// class UtilsController extends GetxController {
//   RxDouble lat = 0.0.obs;
//   RxDouble lng = 0.0.obs;
//   RxString address = "".obs;
//   RxBool panicOn = false.obs;
//   Timer? _locationUpdateTimer;
//   int _panicId = 0;
//
//   MethodChannel platform = MethodChannel('location_service');
//
//   EventChannel eventChannel = EventChannel('location_updates');
//
//   @override
//   void onClose() {
//     _locationUpdateTimer?.cancel();
//     super.onClose();
//   }
//
//   handlePanic() {
//     panicOn.isTrue ? stopSendingPanic() : startSendingPanic();
//   }
//
//   Future<void> getFirstLocation() async {
//     getCurrentLocation();
//   }
//
//   void startSendingPanic() async {
//     await getCurrentLocation();
//     ReportApi().sendPanic(lat.value, lng.value).then((v) {
//       if (v != null) {
//         _panicId = v["alert"]["id"];
//         panicOn.value = true;
//         RandomFunction.toast(
//             ToastType.success, "Panic Has Started Successfully");
//
//         _locationUpdateTimer =
//             Timer.periodic(Duration(minutes: 1), (timer) async {
//           await getCurrentLocation();
//           await ReportApi().updatePanic(lat.value, lng.value, _panicId);
//         });
//       }
//     });
//   }
//
//   Future<void> getCurrentLocation() async {
//     try {
//       await platform.invokeMethod('requestPermission');
//       final bool result = await platform.invokeMethod('checkPermission');
//       if (result) {
//         var first_event = await eventChannel.receiveBroadcastStream().first;
//         if (first_event != null) {
//           List<String> parts = (first_event as String).split(" ");
//
//           double latitude = double.parse(parts[0]);
//           double longitude = double.parse(parts[1]);
//           lat.value = latitude;
//           lng.value = longitude;
//           LocalStorage.saveLat(20);
//           LocalStorage.saveLnt(20);
//           Logger().d("Latitude: $latitude");
//           Logger().d("Longitude: $longitude");
//         }
//       }
//     } on PlatformException catch (e) {
//       Logger().d("Failed to start location updates: '${e.message}'.");
//     }
//   }
//
//   void stopSendingPanic() async {
//     ReportApi().stopPanic().then((v) {
//       if (v != null) {
//         _locationUpdateTimer?.cancel();
//         _locationUpdateTimer = null;
//         panicOn.value = false;
//         RandomFunction.toast(ToastType.info, "Panic Has Ended Successfully");
//       }
//     });
//   }
//
//   Future<bool> requestPermission() async {
//     const permission = Permission.location;
//
//     while (true) {
//       if (await permission.isGranted) {
//         getFirstLocation();
//         return true;
//       } else if (await permission.isPermanentlyDenied) {
//         return false;
//       } else {
//         final result = await permission.request();
//         if (result.isGranted) {
//           getFirstLocation();
//           return true;
//         } else if (result.isPermanentlyDenied) {
//           return false;
//         }
//       }
//     }
//   }
// }

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
            Timer.periodic(const Duration(minutes: 1), (timer) async {
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
