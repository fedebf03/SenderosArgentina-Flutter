import 'package:flutter/material.dart';

import '../../domain/model/sendero.dart';

String kilometros(double distancia) {
  final texto = distancia == distancia.roundToDouble()
      ? distancia.toStringAsFixed(0)
      : distancia.toStringAsFixed(1).replaceAll('.', ',');
  return '$texto km';
}

class IndicadorDificultad extends StatelessWidget {
  final Dificultad dificultad;

  const IndicadorDificultad({super.key, required this.dificultad});

  static const _colores = {
    Dificultad.baja: Color(0xFF2E7D4F),
    Dificultad.media: Color(0xFFC77700),
    Dificultad.alta: Color(0xFFBA1A1A),
  };
  static const textos = {
    Dificultad.baja: 'Baja',
    Dificultad.media: 'Media',
    Dificultad.alta: 'Alta',
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var nivel = 0; nivel < 3; nivel++)
          Container(
            width: 4,
            height: 6.0 + nivel * 4,
            margin: const EdgeInsets.only(right: 2),
            color: nivel <= dificultad.index
                ? _colores[dificultad]
                : tema.colorScheme.outlineVariant,
          ),
        const SizedBox(width: 4),
        Text(
          textos[dificultad]!,
          style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class DatoSendero extends StatelessWidget {
  final String titulo;
  final String valor;

  const DatoSendero(this.titulo, this.valor, {super.key});

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
