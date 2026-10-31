import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaUbicacion extends StatelessWidget {
  final double latitud;
  final double longitud;

  const MapaUbicacion({
    super.key,
    required this.latitud,
    required this.longitud,
  });

  @override
  Widget build(BuildContext context) {
    final punto = LatLng(latitud, longitud);
    return SizedBox(
      height: 200,
      child: FlutterMap(
        // La key hace que el mapa se vuelva a centrar cuando cambia la ubicación
        key: ValueKey(punto),
        options: MapOptions(initialCenter: punto, initialZoom: 14),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.unaj.senderos.senderos_argentina',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: punto,
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
