import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    final hasPermission = await _ensurePermission();
    if (!hasPermission) {
      throw StateError('Location permission is required to register attendance.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double distanceToObra({
    required double employeeLatitude,
    required double employeeLongitude,
    required double obraLatitude,
    required double obraLongitude,
  }) {
    return Geolocator.distanceBetween(
      employeeLatitude,
      employeeLongitude,
      obraLatitude,
      obraLongitude,
    );
  }

  bool isInsideRadius({
    required double employeeLatitude,
    required double employeeLongitude,
    required double obraLatitude,
    required double obraLongitude,
    double radiusMeters = 100,
  }) {
    final distance = distanceToObra(
      employeeLatitude: employeeLatitude,
      employeeLongitude: employeeLongitude,
      obraLatitude: obraLatitude,
      obraLongitude: obraLongitude,
    );

    return distance <= radiusMeters;
  }

  Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
