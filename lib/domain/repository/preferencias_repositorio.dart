import '../model/preferencias.dart';

abstract class PreferenciasRepositorio {
  Future<Preferencias> obtener();

  Future<void> guardar(Preferencias preferencias);
}
