abstract class NotificacionRepositorio {
  Future<void> activarRecordatorio(int hora, int minuto);

  Future<void> desactivarRecordatorio();

  Future<void> avisar(String titulo, String texto);
}
