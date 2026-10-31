import 'package:flutter/material.dart';

import '../../domain/model/sendero.dart';
import '../../domain/repository/notificacion_repositorio.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../../domain/repository/ubicacion_repositorio.dart';
import '../explorar/explorar_pantalla.dart';
import 'formulario_sendero_pantalla.dart';

class MisSenderosPantalla extends StatelessWidget {
  final SenderoRepositorio senderos;
  final UbicacionRepositorio ubicacion;
  final NotificacionRepositorio notificaciones;

  const MisSenderosPantalla({
    super.key,
    required this.senderos,
    required this.ubicacion,
    required this.notificaciones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo sendero',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioSenderoPantalla(
              senderos: senderos,
              ubicacion: ubicacion,
              notificaciones: notificaciones,
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: _lista(),
    );
  }

  Widget _lista() {
    return StreamBuilder<List<Sendero>>(
      stream: senderos.misSenderos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('No pudimos cargar tus senderos'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snapshot.data!;
        if (lista.isEmpty) {
          return const Center(child: Text('Todavía no tenés senderos'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lista.length,
          itemBuilder: (context, indice) => TarjetaSendero(
            sendero: lista[indice],
            senderos: senderos,
            ubicacion: ubicacion,
            notificaciones: notificaciones,
          ),
        );
      },
    );
  }
}
