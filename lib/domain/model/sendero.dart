enum Dificultad { baja, media, alta }

class Sendero {
  final String id;
  final String nombre;
  final String region;
  final double distanciaKilometros;
  final Dificultad dificultad;
  final String descripcion;

  Sendero({
    required this.id,
    required this.nombre,
    required this.region,
    required this.distanciaKilometros,
    required this.dificultad,
    this.descripcion = '',
  });
}
