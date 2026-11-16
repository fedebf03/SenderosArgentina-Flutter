import 'package:flutter_test/flutter_test.dart';
import 'package:senderos_argentina/domain/model/punto.dart';
import 'package:senderos_argentina/domain/model/sendero.dart';

void main() {
  test('sin puntos no hay distancia', () {
    expect(kilometrosRecorridos([]), 0);
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
