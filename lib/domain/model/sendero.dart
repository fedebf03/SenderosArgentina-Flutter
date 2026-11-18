import 'punto.dart';

enum Dificultad { baja, media, alta }

class Sendero {
  final String id;
  final String nombre;
  final String region;
  final double distanciaKilometros;
  final Dificultad dificultad;
  final String descripcion;
  final String autor;
  final String foto;
  final int desnivelMetros;
  final String duracionEstimada;
  final String puntoInicio;
  final String mejorEpoca;
  final double? latitud;
  final double? longitud;
  final List<Punto> recorrido;
  final String idOrigen;

  Sendero({
    required this.id,
    required this.nombre,
    required this.region,
    required this.distanciaKilometros,
    required this.dificultad,
    this.descripcion = '',
    this.autor = '',
    this.foto = '',
    this.desnivelMetros = 0,
    this.duracionEstimada = '',
    this.puntoInicio = '',
    this.mejorEpoca = '',
    this.latitud,
    this.longitud,
    this.recorrido = const [],
    this.idOrigen = '',
  });
}

// RF2 - Explorar: la búsqueda filtra por nombre o región sin distinguir mayúsculas
List<Sendero> filtrarSenderos(
  List<Sendero> senderos,
  String busqueda,
  Set<Dificultad> dificultades,
) {
  final texto = busqueda.trim().toLowerCase();
  return senderos
      .where(
        (sendero) =>
            (sendero.nombre.toLowerCase().contains(texto) ||
                sendero.region.toLowerCase().contains(texto)) &&
            (dificultades.isEmpty || dificultades.contains(sendero.dificultad)),
      )
      .toList();
}

// Un sendero propio que se publicó aparece también en los públicos, así que se saca de ahí
List<Sendero> senderosAjenos(List<Sendero> publicos, List<Sendero> propios) {
  final idsPropios = propios.map((sendero) => sendero.id).toSet();
  return publicos.where((sendero) => !idsPropios.contains(sendero.id)).toList();
}

// Los senderos sin ubicación quedan al final
void ordenarPorCercania(List<Sendero> senderos, Punto ubicacion) {
  double distancia(Sendero sendero) => sendero.latitud == null
      ? double.infinity
      : kilometrosRecorridos([
          ubicacion,
          Punto(sendero.latitud!, sendero.longitud!),
        ]);
  senderos.sort((a, b) => distancia(a).compareTo(distancia(b)));
}
