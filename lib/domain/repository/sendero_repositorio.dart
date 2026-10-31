import '../model/sendero.dart';

abstract class SenderoRepositorio {
  Future<List<Sendero>> obtenerSenderos();

  Stream<List<Sendero>> misSenderos();

  Future<void> guardarSendero(Sendero sendero);
}
