import 'package:geolocator/geolocator.dart';

import '../../domain/repository/ubicacion_repositorio.dart';

class UbicacionRepositorioGeolocator implements UbicacionRepositorio {
  // RF5 - Geolocalización: pide el permiso si hace falta y lee la posición del GPS
  @override
  Future<({double latitud, double longitud})> ubicacionActual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('La ubicación está apagada');
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      throw Exception('Sin permiso de ubicación');
    }
    final posicion = await Geolocator.getCurrentPosition();
    return (latitud: posicion.latitude, longitud: posicion.longitude);
  }
}
