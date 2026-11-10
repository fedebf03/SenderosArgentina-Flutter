import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/model/preferencias.dart';
import '../../domain/repository/preferencias_repositorio.dart';

class PreferenciasRepositorioLocal implements PreferenciasRepositorio {
  static const _claveModoTema = 'modoTema';
  static const _claveRecordatorio = 'recordatorioActivo';
  static const _claveHora = 'horaRecordatorio';
  static const _claveMinuto = 'minutoRecordatorio';

  // Preferencias: se guardan en el celular, no hace falta estar en línea para leerlas
  @override
  Future<Preferencias> obtener() async {
    final datos = await SharedPreferences.getInstance();
    final modo = datos.getString(_claveModoTema);
    return Preferencias(
      modoTema: ModoTema.values.firstWhere(
        (valor) => valor.name == modo,
        orElse: () => ModoTema.sistema,
      ),
      recordatorioActivo: datos.getBool(_claveRecordatorio) ?? false,
      horaRecordatorio: datos.getInt(_claveHora) ?? 9,
      minutoRecordatorio: datos.getInt(_claveMinuto) ?? 0,
    );
  }

  // Guardar las preferencias en el almacenamiento local del celular
  @override
  Future<void> guardar(Preferencias preferencias) async {
    final datos = await SharedPreferences.getInstance();
    await datos.setString(_claveModoTema, preferencias.modoTema.name);
    await datos.setBool(_claveRecordatorio, preferencias.recordatorioActivo);
    await datos.setInt(_claveHora, preferencias.horaRecordatorio);
    await datos.setInt(_claveMinuto, preferencias.minutoRecordatorio);
  }
}
