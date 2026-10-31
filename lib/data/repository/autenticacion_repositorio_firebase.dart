import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/model/usuario.dart';
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

  // RF1 - Registro: Firebase crea la cuenta y deja la sesión iniciada
  @override
  Future<void> registrar(String correo, String clave) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: clave,
      );
    } on FirebaseAuthException catch (e) {
      throw ErrorAutenticacion(
        _mensajeDeError(e.code, porDefecto: 'No se pudo crear la cuenta'),
      );
    } catch (_) {
      throw ErrorAutenticacion('No se pudo crear la cuenta');
    }
  }

  // RF1 - Recuperación: si el correo no tiene cuenta se toma como enviado, así no se revela qué correos están registrados
  @override
  Future<void> enviarCorreoRecuperacion(String correo) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return;
      throw ErrorAutenticacion(
        _mensajeDeError(
          e.code,
          porDefecto: 'No pudimos enviar el correo. Intentá de nuevo.',
        ),
      );
    } catch (_) {
      throw ErrorAutenticacion(
        'No pudimos enviar el correo. Intentá de nuevo.',
      );
    }
  }

  @override
  Usuario? usuarioActual() => _aUsuario(_auth.currentUser);

  // RF1 - Sesión: Firebase guarda el usuario en el dispositivo y avisa cada vez que se entra o se sale
  @override
  Stream<Usuario?> cambiosDeSesion() => _auth.authStateChanges().map(_aUsuario);

  Usuario? _aUsuario(User? usuario) {
    if (usuario == null) return null;
    return Usuario(
      correo: usuario.email ?? '',
      nombre: usuario.displayName ?? '',
      fotoUrl: usuario.photoURL ?? '',
    );
  }

  // RF1 - Sesión: se cierra también la de Google. Si no, el popup vuelve a entrar con la misma cuenta
  @override
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    await _googleListo;
    await GoogleSignIn.instance.signOut();
  }

  String _mensajeDeError(
    String codigo, {
    String porDefecto = 'No se pudo iniciar sesión',
  }) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'El correo no tiene un formato válido';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      default:
        return porDefecto;
    }
  }
}
