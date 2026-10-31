import 'package:flutter/material.dart';

import '../../domain/model/sendero.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../explorar/explorar_pantalla.dart';

class MisSenderosPantalla extends StatelessWidget {
  final SenderoRepositorio senderos;

  const MisSenderosPantalla({super.key, required this.senderos});

  @override
  Widget build(BuildContext context) {
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
          itemBuilder: (context, indice) =>
              TarjetaSendero(sendero: lista[indice]),
        );
      },
    );
  }
}
