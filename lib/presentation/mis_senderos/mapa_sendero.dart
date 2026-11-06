import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/model/punto.dart';

class MapaSendero extends StatefulWidget {
  final Punto? inicio;
  final List<Punto> recorrido;
  final ValueChanged<Punto>? alTocar;
  final Punto? posicion;
  final double? alto;

  const MapaSendero({
    super.key,
    this.inicio,
    this.recorrido = const [],
    this.alTocar,
    this.posicion,
    this.alto = 260,
  });

  @override
  State<MapaSendero> createState() => _MapaSenderoState();
}

class _MapaSenderoState extends State<MapaSendero> {
  MapLibreMapController? _mapa;
  bool _estiloListo = false;

  Punto? get _primerPunto =>
      widget.recorrido.isNotEmpty ? widget.recorrido.first : widget.inicio;

  @override
  void didUpdateWidget(MapaSendero anterior) {
    super.didUpdateWidget(anterior);
    final inicio = widget.inicio;
    if (inicio != null && inicio != anterior.inicio) {
      _mapa?.animateCamera(CameraUpdate.newLatLngZoom(_latLng(inicio), 14));
    }
    final posicion = widget.posicion;
    if (posicion != null && posicion != anterior.posicion) {
      _mapa?.animateCamera(CameraUpdate.newLatLng(_latLng(posicion)));
    }
    _dibujar();
  }

  Future<void> _dibujar() async {
    final mapa = _mapa;
    final inicio = _primerPunto;
    if (mapa == null || !_estiloListo) return;
    final colores = Theme.of(context).colorScheme;
    await mapa.clearLines();
    await mapa.clearCircles();
    if (widget.recorrido.length > 1) {
      await mapa.addLine(
        LineOptions(
          geometry: widget.recorrido.map(_latLng).toList(),
          lineColor: _hex(colores.primary),
          lineWidth: 4,
        ),
      );
    }
    if (inicio != null) {
      await mapa.addCircle(
        CircleOptions(
          geometry: _latLng(inicio),
          circleRadius: 7,
          circleColor: _hex(colores.error),
        ),
      );
    }
    final posicion = widget.posicion;
    if (posicion != null) {
      await mapa.addCircle(
        CircleOptions(
          geometry: _latLng(posicion),
          circleRadius: 8,
          circleColor: _hex(colores.primary),
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inicio = _primerPunto;
    return SizedBox(
      height: widget.alto,
      child: Stack(
        children: [
          MapLibreMap(
            styleString: 'https://tiles.openfreemap.org/styles/liberty',
            initialCameraPosition: inicio == null
                ? const CameraPosition(target: LatLng(-38.4, -63.6), zoom: 3.5)
                : CameraPosition(target: _latLng(inicio), zoom: 14),
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
            },
            onMapCreated: (mapa) => _mapa = mapa,
            onStyleLoadedCallback: () {
              _estiloListo = true;
              _dibujar();
            },
            onMapClick: (_, posicion) => widget.alTocar?.call(
              Punto(posicion.latitude, posicion.longitude),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Acercar',
                  icon: const Icon(Icons.add),
                  onPressed: () => _mapa?.animateCamera(CameraUpdate.zoomIn()),
                ),
                IconButton.filledTonal(
                  tooltip: 'Alejar',
                  icon: const Icon(Icons.remove),
                  onPressed: () => _mapa?.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

LatLng _latLng(Punto punto) => LatLng(punto.latitud, punto.longitud);

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
