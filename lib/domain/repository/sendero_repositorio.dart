import '../model/sendero.dart';

abstract class SenderoRepositorio {
  Future<List<Sendero>> obtenerSenderos();
}
