import '../model/usuario.dart';

class ErrorAutenticacion implements Exception {
  final String mensaje;

  ErrorAutenticacion(this.mensaje);
}

abstract class AutenticacionRepositorio {
  Future<void> iniciarSesion(String correo, String clave);

  Future<void> iniciarSesionConGoogle();

  Future<void> registrar(String correo, String clave);

  Future<void> enviarCorreoRecuperacion(String correo);

  Usuario? usuarioActual();

  Stream<Usuario?> cambiosDeSesion();

  Future<void> cerrarSesion();
}
