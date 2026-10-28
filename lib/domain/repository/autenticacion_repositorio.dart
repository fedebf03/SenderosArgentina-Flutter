class ErrorAutenticacion implements Exception {
  final String mensaje;

  ErrorAutenticacion(this.mensaje);
}

abstract class AutenticacionRepositorio {
  Future<void> iniciarSesion(String correo, String clave);
}
