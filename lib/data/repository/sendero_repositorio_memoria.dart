import '../../domain/model/sendero.dart';
import '../../domain/repository/sendero_repositorio.dart';

// Por ahora los senderos están cargados a mano. Posteriormente se reemplaza por la base local
// y las pantallas no cambian porque solo conocen SenderoRepositorio
class SenderoRepositorioMemoria implements SenderoRepositorio {
  final List<Sendero> _senderos = [
    Sendero(
      id: '1',
      nombre: 'Laguna de los Tres',
      region: 'Santa Cruz',
      distanciaKilometros: 20,
      dificultad: Dificultad.alta,
    ),
    Sendero(
      id: '2',
      nombre: 'Cerro Campanario',
      region: 'Río Negro',
      distanciaKilometros: 1.5,
      dificultad: Dificultad.baja,
    ),
  ];

  @override
  Future<List<Sendero>> obtenerSenderos() async {
    return _senderos;
  }
}
