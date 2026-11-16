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
