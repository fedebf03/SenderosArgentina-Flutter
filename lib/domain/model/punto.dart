import 'dart:math';

class Punto {
  final double latitud;
  final double longitud;

  const Punto(this.latitud, this.longitud);
}

double kilometrosRecorridos(List<Punto> puntos) {
  const radioTierraKm = 6371.0;
  double total = 0;
  for (var i = 1; i < puntos.length; i++) {
    final a = puntos[i - 1];
    final b = puntos[i];
    final dLat = _radianes(b.latitud - a.latitud);
    final dLon = _radianes(b.longitud - a.longitud);
    final h =
        pow(sin(dLat / 2), 2) +
        cos(_radianes(a.latitud)) *
            cos(_radianes(b.latitud)) *
            pow(sin(dLon / 2), 2);
    total += 2 * radioTierraKm * asin(sqrt(h));
  }
  return total;
}

double _radianes(double grados) => grados * pi / 180;
