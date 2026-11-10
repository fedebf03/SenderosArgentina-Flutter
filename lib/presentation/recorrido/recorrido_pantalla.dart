import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/model/punto.dart';
import '../../domain/model/sendero.dart';
import '../../domain/repository/notificacion_repositorio.dart';
import '../../domain/repository/sensores_repositorio.dart';
import '../../domain/repository/ubicacion_repositorio.dart';
import '../explorar/datos_sendero.dart';
import '../explorar/mapa_sendero.dart';

class RecorridoPantalla extends StatefulWidget {
  final Sendero sendero;
  final UbicacionRepositorio ubicacion;
  final SensoresRepositorio sensores;
  final NotificacionRepositorio notificaciones;

  const RecorridoPantalla({
    super.key,
    required this.sendero,
    required this.ubicacion,
    required this.sensores,
    required this.notificaciones,
  });

  @override
  State<RecorridoPantalla> createState() => _RecorridoPantallaState();
}

class _RecorridoPantallaState extends State<RecorridoPantalla> {
  final List<StreamSubscription> _suscripciones = [];
  Punto? _posicion;
  double _recorridos = 0;
  double? _rumbo;
  int _pasos = 0;
  bool _sinUbicacion = false;

  // RF5 - Seguimiento: con cada posición nueva se suma lo caminado desde la anterior
  @override
  void initState() {
    super.initState();
    // RF7 - Notificaciones: avisar que empezó el recorrido
    unawaited(
      widget.notificaciones.avisar(
        'Recorrido iniciado',
        'Arrancaste ${widget.sendero.nombre}. ¡Buen camino!',
      ),
    );
    _suscripciones.addAll([
      widget.ubicacion.seguirUbicacion().listen(
        (actual) => setState(() {
          final nueva = Punto(actual.latitud, actual.longitud);
          if (_posicion != null) {
            _recorridos += kilometrosRecorridos([_posicion!, nueva]);
          }
          _posicion = nueva;
        }),
        onError: (_) => setState(() => _sinUbicacion = true),
      ),
      // Si el celular no tiene el sensor, el dato queda como no disponible
      widget.sensores.rumbo().listen(
        (rumbo) => setState(() => _rumbo = rumbo),
        onError: (_) {},
      ),
      widget.sensores.pasos().listen(
        (pasos) => setState(() => _pasos = pasos),
        onError: (_) {},
      ),
    ]);
  }

  @override
  void dispose() {
    for (final suscripcion in _suscripciones) {
      suscripcion.cancel();
    }
    // Avisar el fin al salir, ya sea con Finalizar o con la flecha de atrás
    unawaited(
      widget.notificaciones.avisar(
        'Recorrido finalizado',
        '${widget.sendero.nombre}: ${kilometros(_recorridos)} y $_pasos pasos',
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restantes = max(
      0.0,
      widget.sendero.distanciaKilometros - _recorridos,
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.sendero.nombre)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MapaSendero(
                recorrido: widget.sendero.recorrido,
                posicion: _posicion,
                alto: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_sinUbicacion)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'No pudimos obtener tu ubicación',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DatoSendero('Recorrido', kilometros(_recorridos)),
                      DatoSendero('Restante', kilometros(restantes)),
                      DatoSendero('Pasos', '$_pasos'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rumbo',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          _rumbo == null
                              ? const Text('No disponible')
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.rotate(
                                      angle: _rumbo! * pi / 180,
                                      child: const Icon(Icons.navigation),
                                    ),
                                    Text(' ${_rumbo!.round()}°'),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Finalizar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
