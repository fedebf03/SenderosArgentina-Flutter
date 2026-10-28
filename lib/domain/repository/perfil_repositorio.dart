import '../model/perfil.dart';

abstract class PerfilRepositorio {
  Future<Perfil> obtener();

  Future<void> guardar(Perfil perfil);
}
