import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Verifica e solicita permissões de localização
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Serviço de localização está desabilitado. '
        'Ative o GPS nas configurações do dispositivo.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Permissão de localização negada. '
          'Conceda a permissão para usar esta funcionalidade.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente. '
        'Vá em Configurações > Apps > ${_getAppName()} > Permissões > Localização e ative.',
      );
    }

    return true;
  }

  /// Obtém o nome do app para orientações do usuário
  String _getAppName() {
    return 'Minhas Tarefas'; // Nome do seu app
  }

  /// Obtém a posição atual do dispositivo
  Future<Position> getCurrentPosition() async {
    await requestLocationPermission();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Verifica se as permissões de localização estão concedidas
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Calcula a distância entre duas coordenadas em metros
  double calculateDistance(
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

  /// Verifica se o dispositivo está próximo a uma localização (raio em metros)
  Future<bool> isNearLocation(
    double targetLatitude,
    double targetLongitude, {
    double radiusInMeters = 100,
  }) async {
    try {
      final position = await getCurrentPosition();
      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        targetLatitude,
        targetLongitude,
      );
      return distance <= radiusInMeters;
    } catch (e) {
      return false;
    }
  }
}
