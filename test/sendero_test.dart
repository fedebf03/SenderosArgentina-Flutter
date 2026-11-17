import 'package:flutter_test/flutter_test.dart';
import 'package:senderos_argentina/domain/model/punto.dart';
import 'package:senderos_argentina/domain/model/sendero.dart';

void main() {
  test('sin puntos no hay distancia', () {
    expect(kilometrosRecorridos([]), 0);
  });

  test('con un solo punto tampoco hay distancia', () {
    expect(kilometrosRecorridos([const Punto(-34.6, -58.4)]), 0);
  });

  test('un grado de longitud sobre el ecuador son unos 111 km', () {
    final distancia = kilometrosRecorridos([
      const Punto(0, 0),
      const Punto(0, 1),
    ]);
    expect(distancia, closeTo(111.19, 0.01));
  });

  test('la distancia suma todos los tramos', () {
    final distancia = kilometrosRecorridos([
      const Punto(0, 0),
      const Punto(0, 1),
      const Punto(0, 2),
    ]);
    expect(distancia, closeTo(222.39, 0.01));
  });

  test('un sendero nuevo arranca sin recorrido', () {
    final sendero = Sendero(
      id: '1',
      nombre: 'Cerro Catedral',
      region: 'Patagonia',
      distanciaKilometros: 5,
      dificultad: Dificultad.media,
    );
    expect(sendero.nombre, 'Cerro Catedral');
    expect(sendero.recorrido, isEmpty);
  });
}
