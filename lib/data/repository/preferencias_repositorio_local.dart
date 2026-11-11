import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/model/preferencias.dart';
import '../../domain/repository/preferencias_repositorio.dart';

class PreferenciasRepositorioLocal implements PreferenciasRepositorio {
  static const _claveModoTema = 'modoTema';

  @override
  Future<ModoTema> modoTema() async {
    final datos = await SharedPreferences.getInstance();
    final guardado = datos.getString(_claveModoTema);
    return ModoTema.values.firstWhere(
      (modo) => modo.name == guardado,
      orElse: () => ModoTema.sistema,
    );
  }

  @override
  Future<void> guardarModoTema(ModoTema modo) async {
    final datos = await SharedPreferences.getInstance();
    await datos.setString(_claveModoTema, modo.name);
  }
}
