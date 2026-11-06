import '../model/sendero.dart';

abstract class SenderoRepositorio {
  Stream<List<Sendero>> senderosPublicos();

  Stream<List<Sendero>> misSenderos();

  Future<void> guardarSendero(Sendero sendero);

  Future<void> publicar(String idSendero);

  Future<void> despublicar(String idSendero);
}
