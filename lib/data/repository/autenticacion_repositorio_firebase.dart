import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repository/autenticacion_repositorio.dart';

class AutenticacionRepositorioFirebase implements AutenticacionRepositorio {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // RF1 - Login: Firebase Auth valida el correo y la clave, y el error se traduce a un mensaje en español
  @override
  Future<void> iniciarSesion(String correo, String clave) async {
    try {
      await _auth.signInWithEmailAndPassword(email: correo, password: clave);
    } on FirebaseAuthException catch (e) {
      throw ErrorAutenticacion(_mensajeDeError(e.code));
    } catch (_) {
      throw ErrorAutenticacion('No se pudo iniciar sesión');
    }
  }

  String _mensajeDeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      default:
        return 'No se pudo iniciar sesión';
    }
  }
}
