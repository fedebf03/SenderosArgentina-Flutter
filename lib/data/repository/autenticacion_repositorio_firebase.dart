import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  // GoogleSignIn se tiene que inicializar una sola vez antes de usarlo
  late final Future<void> _googleListo = GoogleSignIn.instance.initialize();

  // RF1 - Google: se elige la cuenta en el popup de Google y con su token se inicia sesión en Firebase
  @override
  Future<void> iniciarSesionConGoogle() async {
    try {
      await _googleListo;
      final cuenta = await GoogleSignIn.instance.authenticate();
      final credencial = GoogleAuthProvider.credential(
        idToken: cuenta.authentication.idToken,
      );
      await _auth.signInWithCredential(credencial);
    } on GoogleSignInException catch (e) {
      throw ErrorAutenticacion(
        e.code == GoogleSignInExceptionCode.canceled
            ? 'Se canceló el inicio de sesión'
            : 'No se pudo iniciar sesión',
      );
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
