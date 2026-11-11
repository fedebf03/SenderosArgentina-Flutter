import '../model/preferencias.dart';

abstract class PreferenciasRepositorio {
  Future<ModoTema> modoTema();

  Future<void> guardarModoTema(ModoTema modo);
}
