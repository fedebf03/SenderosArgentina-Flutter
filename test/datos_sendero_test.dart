import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senderos_argentina/domain/model/sendero.dart';
import 'package:senderos_argentina/presentation/explorar/datos_sendero.dart';

void main() {
  test('los kilómetros enteros se muestran sin decimales', () {
    expect(kilometros(12), '12 km');
  });

  test('los kilómetros con decimales usan coma', () {
    expect(kilometros(3.5), '3,5 km');
  });

  testWidgets('el indicador muestra el texto de la dificultad', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: IndicadorDificultad(dificultad: Dificultad.alta)),
      ),
    );
    expect(find.text('Alta'), findsOneWidget);
  });

  testWidgets('el dato muestra título y valor', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DatoSendero('Desnivel', '350 m'))),
    );
    expect(find.text('Desnivel'), findsOneWidget);
    expect(find.text('350 m'), findsOneWidget);
  });
}
