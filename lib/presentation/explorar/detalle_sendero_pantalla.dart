import 'package:flutter/material.dart';

import '../../domain/model/sendero.dart';
import 'datos_sendero.dart';

class DetalleSenderoPantalla extends StatelessWidget {
  final Sendero sendero;

  const DetalleSenderoPantalla({super.key, required this.sendero});

  // RF3 - Detalle: se muestran los datos técnicos y la información del sendero elegido en Explorar
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final gris = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(title: Text(sendero.nombre)),
      body: ListView(
        children: [
          if (sendero.foto.isNotEmpty)
            Image.network(
              sendero.foto,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sendero.region, style: gris),
                if (sendero.autor.isNotEmpty)
                  Text('Por ${sendero.autor}', style: gris),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _Dato('Distancia', kilometros(sendero.distanciaKilometros)),
                    if (sendero.desnivelMetros > 0)
                      _Dato('Desnivel', '${sendero.desnivelMetros} m'),
                    if (sendero.duracionEstimada.isNotEmpty)
                      _Dato('Duración', sendero.duracionEstimada),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dificultad', style: tema.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        IndicadorDificultad(dificultad: sendero.dificultad),
                      ],
                    ),
                  ],
                ),
                _Seccion('Descripción', sendero.descripcion),
                _Seccion('Punto de inicio', sendero.puntoInicio),
                _Seccion('Mejor época', sendero.mejorEpoca),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String titulo;
  final String valor;

  const _Dato(this.titulo, this.valor);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: tema.textTheme.labelSmall),
        Text(
          valor,
          style: tema.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String texto;

  const _Seccion(this.titulo, this.texto);

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) return const SizedBox.shrink();
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: tema.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(texto),
        ],
      ),
    );
  }
}
