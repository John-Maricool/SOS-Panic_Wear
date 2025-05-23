import 'package:flutter/services.dart';

class LocationService {
  static const MethodChannel _channel = MethodChannel('location_service');

  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final Map<dynamic, dynamic>? locationData =
          await _channel.invokeMethod('getCurrentLocation');
      return {
        'latitude': locationData?['latitude'] as double,
        'longitude': locationData?['longitude'] as double,
      };
    } on PlatformException catch (e) {
      print("Failed to get location: '${e.message}'.");
      return null;
    }
  }
}
