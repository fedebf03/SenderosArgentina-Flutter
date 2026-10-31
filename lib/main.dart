import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/repository/autenticacion_repositorio_firebase.dart';
import 'data/repository/notificacion_repositorio_local.dart';
import 'data/repository/perfil_repositorio_firestore.dart';
import 'data/repository/sendero_repositorio_firestore.dart';
import 'data/repository/ubicacion_repositorio_geolocator.dart';
import 'domain/model/usuario.dart';
import 'presentation/auth/login_pantalla.dart';
import 'presentation/inicio/inicio_pantalla.dart';
import 'presentation/tema.dart';

Future<void> main() async {
  // Firebase tiene que estar listo antes de dibujar la primera pantalla
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SenderosApp());
}

class SenderosApp extends StatelessWidget {
  const SenderosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final autenticacion = AutenticacionRepositorioFirebase();
    final perfiles = PerfilRepositorioFirestore();
    final senderos = SenderoRepositorioFirestore();
    final ubicacion = UbicacionRepositorioGeolocator();
    final notificaciones = NotificacionRepositorioLocal();
    return MaterialApp(
      title: 'Senderos Argentina',
      debugShowCheckedModeBanner: false,
      theme: temaSenderos,
      // Al iniciar o cerrar sesión la pantalla principal cambia sola, sin navegar a mano
      home: StreamBuilder<Usuario?>(
        stream: autenticacion.cambiosDeSesion(),
        initialData: autenticacion.usuarioActual(),
        builder: (context, sesion) => sesion.data != null
            ? InicioPantalla(
                autenticacion: autenticacion,
                perfiles: perfiles,
                senderos: senderos,
                ubicacion: ubicacion,
                notificaciones: notificaciones,
              )
            : LoginPantalla(repositorio: autenticacion),
      ),
    );
  }
}
