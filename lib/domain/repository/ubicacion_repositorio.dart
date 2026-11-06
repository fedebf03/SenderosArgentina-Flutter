abstract class UbicacionRepositorio {
  Future<({double latitud, double longitud})> ubicacionActual();

  Stream<({double latitud, double longitud})> seguirUbicacion();
}
