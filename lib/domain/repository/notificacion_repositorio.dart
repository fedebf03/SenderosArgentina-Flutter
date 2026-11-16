abstract class NotificacionRepositorio {
  Future<void> mostrarRecorrido(String titulo, String texto, DateTime inicio);

  Future<void> cerrarRecorrido();
}
