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

import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:location/location.dart'
    as l; // Replace geolocator with location
import '../apis/report_api.dart';
import 'package:permission_handler/permission_handler.dart';
import '../random_functions.dart';

class UtilsController extends GetxController {
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxString address = "".obs;
  RxBool panicOn = false.obs;
  l.Location location = l.Location();

  @override
  void onInit() async {
    super.onInit();
    // requestPermission();
  }

  handlePanic() {
    panicOn.isTrue ? stopSendingPanic() : startSendingPanic();
  }

  startSendingPanic() async {
    ReportApi().sendPanic().then((v) {
      if (v != null) {
        panicOn.value = true;
        RandomFunction.toast(
            ToastType.success, "Panic Has Started Successfully");
      }
    });
  }

  stopSendingPanic() async {
    // Stop listening for location changes
    ReportApi().stopPanic().then((v) {
      if (v != null) {
        panicOn.value = false;
        RandomFunction.toast(ToastType.info, "Panic Has Ended Successfully");
      }
    });
  }

  getDeviceLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw "Location services are disabled.";
        }
      }

      // Get the current location
      l.LocationData currentLocation = await location.getLocation();
      var placemarks = await placemarkFromCoordinates(
        currentLocation.latitude ?? 0.0,
        currentLocation.longitude ?? 0.0,
      );

      // Update address and coordinates
      address.value =
          "${placemarks.first.subLocality} ${placemarks.first.administrativeArea ?? ""},  ${placemarks.first.country ?? ""}";
      lat.value = currentLocation.latitude ?? 0.0;
      lng.value = currentLocation.longitude ?? 0.0;
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
