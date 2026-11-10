import 'package:flutter_test/flutter_test.dart';
import 'package:senderos_argentina/data/repository/preferencias_repositorio_local.dart';
import 'package:senderos_argentina/domain/model/preferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Verificar que las preferencias se guardan en el celular y vuelven igual
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sin datos guardados devuelve los valores por defecto', () async {
    final preferencias = await PreferenciasRepositorioLocal().obtener();

    expect(preferencias.modoTema, ModoTema.sistema);
    expect(preferencias.recordatorioActivo, isFalse);
    expect(preferencias.horaRecordatorio, 9);
    expect(preferencias.minutoRecordatorio, 0);
  });

  test('lo guardado se recupera al volver a leer', () async {
    final repositorio = PreferenciasRepositorioLocal();

    await repositorio.guardar(
      const Preferencias(
        modoTema: ModoTema.oscuro,
        recordatorioActivo: true,
        horaRecordatorio: 18,
        minutoRecordatorio: 30,
      ),
    );
    final leidas = await PreferenciasRepositorioLocal().obtener();

    expect(leidas.modoTema, ModoTema.oscuro);
    expect(leidas.recordatorioActivo, isTrue);
    expect(leidas.horaRecordatorio, 18);
    expect(leidas.minutoRecordatorio, 30);
  });
}
