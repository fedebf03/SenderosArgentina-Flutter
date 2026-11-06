import 'package:geolocator/geolocator.dart';

import '../../domain/repository/ubicacion_repositorio.dart';

class UbicacionRepositorioGeolocator implements UbicacionRepositorio {
  // RF5 - Geolocalización: pide el permiso si hace falta y lee la posición del GPS
  @override
  Future<({double latitud, double longitud})> ubicacionActual() async {
    await _pedirPermiso();
    final posicion = await Geolocator.getCurrentPosition();
    return (latitud: posicion.latitude, longitud: posicion.longitude);
  }

  // RF5 - Seguimiento: llega una posición nueva cada vez que el usuario se mueve 5 metros
  @override
  Stream<({double latitud, double longitud})> seguirUbicacion() async* {
    await _pedirPermiso();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 5),
    ).map(
      (posicion) => (latitud: posicion.latitude, longitud: posicion.longitude),
    );
  }

  Future<void> _pedirPermiso() async {
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
  }
}
