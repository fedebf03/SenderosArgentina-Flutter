import 'package:flutter/material.dart';

import '../../domain/model/punto.dart';
import '../../domain/model/sendero.dart';
import '../../domain/repository/foto_repositorio.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../../domain/repository/sensores_repositorio.dart';
import '../../domain/repository/ubicacion_repositorio.dart';
import '../editar_sendero/formulario_sendero_pantalla.dart';
import '../recorrido/recorrido_pantalla.dart';
import 'datos_sendero.dart';
import 'mapa_sendero.dart';

class DetalleSenderoPantalla extends StatelessWidget {
  final Sendero sendero;
  final UbicacionRepositorio ubicacion;
  final SensoresRepositorio sensores;
  final SenderoRepositorio? senderos;
  final FotoRepositorio? fotos;

  const DetalleSenderoPantalla({
    super.key,
    required this.sendero,
    required this.ubicacion,
    required this.sensores,
    this.senderos,
    this.fotos,
  });

  // RF2 - Publicar: el sendero propio se comparte con todos o se deja de compartir
  Future<void> _cambiarPublicacion(BuildContext context, bool publicado) async {
    final mensajes = ScaffoldMessenger.of(context);
    try {
      publicado
          ? await senderos!.despublicar(sendero.id)
          : await senderos!.publicar(sendero.id);
      mensajes.showSnackBar(
        SnackBar(
          content: Text(
            publicado ? 'El sendero ya no es público' : 'Sendero publicado',
          ),
        ),
      );
    } catch (_) {
      mensajes.showSnackBar(
        const SnackBar(content: Text('No pudimos cambiar la publicación')),
      );
    }
  }

  // RF3 - Detalle: se muestran los datos técnicos y la información del sendero elegido en Explorar
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final gris = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(sendero.nombre),
        actions: [
          if (senderos != null && fotos != null) ...[
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioSenderoPantalla(
                    senderos: senderos!,
                    ubicacion: ubicacion,
                    fotos: fotos!,
                    sendero: sendero,
                  ),
                ),
              ),
            ),
            StreamBuilder<List<Sendero>>(
              stream: senderos!.senderosPublicos(),
              builder: (context, publicos) {
                final publicado = (publicos.data ?? []).any(
                  (publico) => publico.id == sendero.id,
                );
                return PopupMenuButton<void>(
                  tooltip: 'Más opciones',
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      onTap: () => _cambiarPublicacion(context, publicado),
                      child: Text(publicado ? 'Dejar de publicar' : 'Publicar'),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
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
                    DatoSendero(
                      'Distancia',
                      kilometros(sendero.distanciaKilometros),
                    ),
                    if (sendero.desnivelMetros > 0)
                      DatoSendero('Desnivel', '${sendero.desnivelMetros} m'),
                    if (sendero.duracionEstimada.isNotEmpty)
                      DatoSendero('Duración', sendero.duracionEstimada),
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
                if (sendero.latitud != null && sendero.longitud != null) ...[
                  const SizedBox(height: 24),
                  MapaSendero(
                    inicio: Punto(sendero.latitud!, sendero.longitud!),
                    recorrido: sendero.recorrido,
                  ),
                ],
                if (sendero.recorrido.length > 1) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecorridoPantalla(
                          sendero: sendero,
                          ubicacion: ubicacion,
                          sensores: sensores,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.directions_walk),
                    label: const Text('Iniciar recorrido'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
