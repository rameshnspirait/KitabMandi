import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// 🔐 Check & request permission
  static Future<bool> handlePermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// 📍 Get current location (lat/lng)
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await handlePermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // ⏱️ prevent freeze
      );
    } catch (e) {
      return null;
    }
  }

  /// 📍 Get formatted location (OLX style)
  static Future<String?> getCurrentCity() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      /// 🔥 Smart fallback logic
      final subLocality = place.subLocality;
      final locality = place.locality ?? place.subAdministrativeArea;
      final state = place.administrativeArea;

      /// 🎯 Format: Area, City
      final location = [
        subLocality,
        locality,
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      /// Optional: if you want state also
      // final location = [
      //   subLocality,
      //   locality,
      //   state,
      // ].where((e) => e != null && e.isNotEmpty).join(', ');

      return location.isNotEmpty ? location : state;
    } catch (e) {
      return null;
    }
  }
}
