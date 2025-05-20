// import 'dart:async';
//
// import 'package:get/get.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:logger/logger.dart';
// import '../apis/report_api.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../random_functions.dart';
//
// class UtilsController extends GetxController {
//   RxDouble lat = 0.0.obs;
//   RxDouble lng = 0.0.obs;
//   RxString address = "".obs;
//   RxBool panicOn = false.obs;
//   StreamSubscription<Position>? _positionStream;
//
//   @override
//   void onInit() async {
//     super.onInit();
//     // requestPermission();
//   }
//
//   handlePanic() {
//     panicOn.isTrue ? stopSendingPanic() : startSendingPanic();
//   }
//
//   startSendingPanic() async {
//     // Start listening for location changes
//     Logger().e(lat.value);
//     Logger().e(lng.value);
//     ReportApi().sendPanic(lat.value, lng.value).then((v) {
//       if (v != null) {
//         panicOn.value = true;
//         RandomFunction.toast(
//             ToastType.success, "Panic Has Started Successfully");
//         _positionStream =
//             Geolocator.getPositionStream().listen((Position position) async {
//           lat.value = position.latitude;
//           lng.value = position.longitude;
//           Logger().e(lat.value);
//           Logger().e(lng.value);
//
//           await ReportApi().updatePanic(lat.value, lng.value, v["alert"]["id"]);
//         });
//       }
//     });
//   }
//
//   stopSendingPanic() async {
//     // Stop listening for location changes
//     _positionStream?.cancel();
//     _positionStream = null;
//     panicOn.value = false;
//     RandomFunction.toast(ToastType.info, "Panic Has Ended Successfully");
//   }
//
//   getDeviceLocation() async {
//     try {
//       var position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       var placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//       print(placemarks.first.country);
//       print(placemarks.first.administrativeArea);
//       print(placemarks.first.subLocality);
//       address.value =
//           "${placemarks.first.subLocality} ${placemarks.first.administrativeArea ?? ""},  ${placemarks.first.country ?? ""}";
//       lat.value = position.latitude;
//       lng.value = position.longitude;
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
//
//   Future<bool> requestPermission() async {
//     const permission = Permission.location;
//
//     while (true) {
//       if (await permission.isGranted) {
//         getDeviceLocation();
//         return true;
//       } else if (await permission.isPermanentlyDenied) {
//         return false;
//       } else {
//         final result = await permission.request();
//         if (result.isGranted) {
//           getDeviceLocation();
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
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:location/location.dart'
    as l; // Replace geolocator with location
import 'package:sos_wear_app/local_storage.dart';
import '../apis/report_api.dart';
import 'package:permission_handler/permission_handler.dart';
import '../random_functions.dart';

class UtilsController extends GetxController {
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxString address = "".obs;
  RxBool panicOn = false.obs;
  StreamSubscription? _eventSubscription;

  MethodChannel platform = MethodChannel('location_service');
  EventChannel eventChannel = EventChannel('location_updates');

  @override
  void onInit() async {
    super.onInit();
    getFirstLocation();
  }

  handlePanic() {
    panicOn.isTrue ? stopSendingPanic() : startSendingPanic();
  }

  Future<void> startLocationUpdates(int id) async {
    try {
      await platform.invokeMethod('requestPermission');
      final bool result = await platform.invokeMethod('checkPermission');
      if (result) {
        _eventSubscription =
            eventChannel.receiveBroadcastStream().listen((event) async {
          if (event != null) {
            List<String> parts = (event as String).split(" ");

            double latitude = double.parse(parts[0]);
            double longitude = double.parse(parts[1]);
            lat.value = latitude;
            lng.value = longitude;
            ReportApi().updatePanic(lat.value, lng.value, id);
          }
        });
      }
    } on PlatformException catch (e) {
      print("Failed to start location updates: '${e.message}'.");
    }
  }

  Future<void> getFirstLocation() async {
    try {
      await platform.invokeMethod('requestPermission');
      final bool result = await platform.invokeMethod('checkPermission');
      if (result) {
        var first_event = await eventChannel.receiveBroadcastStream().first;
        if (first_event != null) {
          List<String> parts = (first_event as String).split(" ");

          double latitude = double.parse(parts[0]);
          double longitude = double.parse(parts[1]);
          lat.value = latitude;
          lng.value = longitude;
          LocalStorage.saveLat(lat.value);
          LocalStorage.saveLnt(lng.value);
          Logger().d("Latitude: $latitude");
          Logger().d("Longitude: $longitude");
        }
      }
    } on PlatformException catch (e) {
      Logger().d("Failed to start location updates: '${e.message}'.");
    }
  }

  startSendingPanic() async {
    ReportApi()
        .sendPanic(
      lat.value == 0 ? LocalStorage.getLat().toDouble() : lat.value.toDouble(),
      lng.value == 0 ? LocalStorage.getLnt().toDouble() : lng.value.toDouble(),
    )
        .then((v) {
      if (v != null) {
        panicOn.value = true;
        RandomFunction.toast(
            ToastType.success, "Panic Has Started Successfully");
        startLocationUpdates(v["alert"]["id"]);
      }
    });
  }

  stopSendingPanic() async {
    ReportApi().stopPanic().then((v) {
      if (v != null) {
        panicOn.value = false;
        _eventSubscription?.cancel();
        _eventSubscription = null;
        RandomFunction.toast(ToastType.info, "Panic Has Ended Successfully");
      }
    });
  }

  Future<bool> requestPermission() async {
    const permission = Permission.location;

    while (true) {
      if (await permission.isGranted) {
        getFirstLocation();
        return true;
      } else if (await permission.isPermanentlyDenied) {
        return false;
      } else {
        final result = await permission.request();
        if (result.isGranted) {
          getFirstLocation();
          return true;
        } else if (result.isPermanentlyDenied) {
          return false;
        }
      }
    }
  }
}
