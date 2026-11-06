import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import '../../domain/repository/sensores_repositorio.dart';

class SensoresRepositorioSensorsPlus implements SensoresRepositorio {
  // RF6 - Brújula: el rumbo sale del magnetómetro, con el celular apoyado horizontal
  @override
  Stream<double> rumbo() => magnetometerEventStream().map(
    (campo) => (atan2(-campo.x, campo.y) * 180 / pi + 360) % 360,
  );

  // RF6 - Pasos: a la fuerza del acelerómetro se le resta la gravedad y cada pico cuenta como un paso
  @override
  Stream<int> pasos() async* {
    var cantidad = 0;
    var ultimoPaso = DateTime(0);
    await for (final evento in accelerometerEventStream()) {
      final fuerza =
          sqrt(
            evento.x * evento.x + evento.y * evento.y + evento.z * evento.z,
          ) -
          9.81;
      final ahora = DateTime.now();
      // Dos picos con menos de 300 ms de diferencia son el mismo paso
      if (fuerza > 2 && ahora.difference(ultimoPaso).inMilliseconds > 300) {
        ultimoPaso = ahora;
        yield ++cantidad;
      }
    }
  }
}
