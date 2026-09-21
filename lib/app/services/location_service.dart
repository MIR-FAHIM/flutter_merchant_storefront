import 'package:device_info_plus/device_info_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class LocationService extends GetxService {
  final currentLocation = {}.obs;
  final imei = ''.obs;
  final model = ''.obs;
  final imeiLoaded = false.obs;
  @override
  void onInit() async {
    print('called');
    getDeviceInfo();
    determinePosition();

    super.onInit();
  }
  // Future<PermissionStatus> getPhonePermission() async {
  //   final PermissionStatus permission = await Permission.phone.status;
  //   print("kaj ekhane hocche location service permissioon status  ${Permission.phone.status.isGranted}");
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.denied) {
  //     final Map<Permission, PermissionStatus> permissionStatus =
  //     await [Permission.phone].request();
  //     return permissionStatus[Permission.phone] ??
  //         PermissionStatus.restricted;
  //
  //     }
  //   if (permission == PermissionStatus.granted) {
  //
  //    print("permision ache *********");
  //    return permission;
  //   }
  //   else {
  //     print("kaj ekhane hocche location service theke");
  //
  //
  //     return permission;
  //   }
  // }
  Future<void> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      print('Android ID: ${androidInfo.id}');
      print('Model: ${androidInfo.model}');

      imei.value = androidInfo.id;    // unique per device+signing key
      model.value = androidInfo.model;
    } catch (e) {
      print('Failed to get device info: $e');
    }
  }

  Future<Map<String, dynamic>> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permissions denied: $permission');
      }

      // Step 1: Immediately use last known position if available for instant coordinates
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          final m = {
            'lat': position.latitude,
            'lng': position.longitude,
            'lon': position.longitude,
            'city': currentLocation['city'] ?? '',
          };
          currentLocation.assignAll(m);
        }
      } catch (e) {
        print('Error getting last known position: $e');
      }

      // Step 2: Fetch current live position with a timeout
      try {
        final livePosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 6),
        );
        position = livePosition;
      } catch (e) {
        print('High accuracy getCurrentPosition failed or timed out ($e), trying lower accuracy');
        try {
          final fallbackPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 4),
          );
          position = fallbackPosition;
        } catch (e2) {
          print('Fallback getCurrentPosition also failed: $e2');
        }
      }

      if (position != null) {
        String city = '';
        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks[0];
            city = place.locality?.isNotEmpty == true
                ? place.locality!
                : (place.administrativeArea ?? '');
          }
        } catch (e) {
          print('Reverse geocoding error: $e');
        }

        final m = {
          'lat': position.latitude,
          'lng': position.longitude,
          'lon': position.longitude,
          'city': city,
        };
        currentLocation.assignAll(m);
        return m;
      }
    } catch (e) {
      print('determinePosition general error: $e');
    }

    return Map<String, dynamic>.from(currentLocation);
  }
}
