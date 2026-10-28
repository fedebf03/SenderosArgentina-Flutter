import 'package:flutter/material.dart';

import '../../domain/model/sendero.dart';
import '../../domain/repository/sendero_repositorio.dart';
import 'datos_sendero.dart';

class ExplorarPantalla extends StatefulWidget {
  final SenderoRepositorio senderos;

  const ExplorarPantalla({super.key, required this.senderos});

  @override
  State<ExplorarPantalla> createState() => _ExplorarPantallaState();
}

class _ExplorarPantallaState extends State<ExplorarPantalla> {
  late final Future<List<Sendero>> _senderos = widget.senderos
      .obtenerSenderos();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sendero>>(
      future: _senderos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('No pudimos cargar los senderos públicos'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final senderos = snapshot.data!;
        if (senderos.isEmpty) {
          return const Center(
            child: Text('Todavía no hay senderos publicados'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: senderos.length,
          itemBuilder: (context, indice) =>
              _TarjetaSendero(sendero: senderos[indice]),
        );
      },
    );
  }
}

class _TarjetaSendero extends StatelessWidget {
  final Sendero sendero;

  const _TarjetaSendero({required this.sendero});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final gris = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _Foto(url: sendero.foto),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sendero.nombre,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(sendero.region, style: gris),
                  if (sendero.autor.isNotEmpty)
                    Text('Por ${sendero.autor}', style: gris),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        kilometros(sendero.distanciaKilometros),
                        style: gris,
                      ),
                      if (sendero.duracionEstimada.isNotEmpty)
                        Text(' · ${sendero.duracionEstimada}', style: gris),
                      const Spacer(),
                      IndicadorDificultad(dificultad: sendero.dificultad),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  final String url;

  const _Foto({required this.url});

  @override
  Widget build(BuildContext context) {
    final sinFoto = Container(
      width: 96,
      height: 110,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Icon(Icons.terrain),
    );
    if (url.isEmpty) return sinFoto;
    return Image.network(
      url,
      width: 96,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => sinFoto,
    );
  }
}
