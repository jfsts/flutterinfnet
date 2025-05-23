import 'package:geolocator/geolocator.dart';

class LocationService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  /// Verifica se os serviços de localização estão habilitados
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Verifica e solicita permissões de localização
  static Future<LocationPermissionStatus> checkAndRequestPermission() async {
    // Verifica primeiro se o serviço de localização está habilitado
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Verifica a permissão atual
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  /// Obtém a localização atual do dispositivo
  static Future<Position?> getCurrentLocation() async {
    try {
      final permissionStatus = await checkAndRequestPermission();

      if (permissionStatus != LocationPermissionStatus.granted) {
        throw LocationException('Permissão de localização negada');
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
    } catch (e) {
      throw LocationException('Erro ao obter localização: $e');
    }
  }

  /// Abre as configurações de localização do dispositivo
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Abre as configurações do app  static Future<void> openAppSettings() async {    await Geolocator.openAppSettings();  }

  /// Calcula a distância entre duas coordenadas (em metros)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}
