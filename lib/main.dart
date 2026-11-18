import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/repository/autenticacion_repositorio_firebase.dart';
import 'data/repository/foto_repositorio_cloudinary.dart';
import 'data/repository/notificacion_repositorio_local.dart';
import 'data/repository/perfil_repositorio_firestore.dart';
import 'data/repository/preferencias_repositorio_local.dart';
import 'data/repository/sendero_repositorio_firestore.dart';
import 'data/repository/sensores_repositorio_celular.dart';
import 'data/repository/ubicacion_repositorio_geolocator.dart';
import 'domain/model/preferencias.dart';
import 'domain/model/usuario.dart';
import 'domain/repository/preferencias_repositorio.dart';
import 'firebase_options.dart';
import 'presentation/auth/login_pantalla.dart';
import 'presentation/inicio/inicio_pantalla.dart';
import 'presentation/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // El tema guardado se lee antes de dibujar para que no aparezca uno y cambie enseguida
  final preferencias = PreferenciasRepositorioLocal();
  final modoTema = await preferencias.modoTema();
  runApp(
    SenderosApp(preferencias: preferencias, modoTema: ValueNotifier(modoTema)),
  );
}

class SenderosApp extends StatelessWidget {
  final PreferenciasRepositorio preferencias;
  final ValueNotifier<ModoTema> modoTema;

  const SenderosApp({
    super.key,
    required this.preferencias,
    required this.modoTema,
  });

  ThemeMode _modoFlutter(ModoTema modo) => switch (modo) {
    ModoTema.sistema => ThemeMode.system,
    ModoTema.claro => ThemeMode.light,
    ModoTema.oscuro => ThemeMode.dark,
  };

  @override
  Widget build(BuildContext context) {
    final autenticacion = AutenticacionRepositorioFirebase();
    final perfiles = PerfilRepositorioFirestore();
    final senderos = SenderoRepositorioFirestore();
    final ubicacion = UbicacionRepositorioGeolocator();
    final fotos = FotoRepositorioCloudinary();
    final sensores = SensoresRepositorioCelular();
    final notificaciones = NotificacionRepositorioLocal();
    return ValueListenableBuilder<ModoTema>(
      valueListenable: modoTema,
      builder: (context, modo, _) => MaterialApp(
        title: 'Senderos Argentina',
        debugShowCheckedModeBanner: false,
        theme: temaSenderos,
        darkTheme: temaSenderosOscuro,
        themeMode: _modoFlutter(modo),
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
                  fotos: fotos,
                  sensores: sensores,
                  preferencias: preferencias,
                  modoTema: modoTema,
                  notificaciones: notificaciones,
                )
              : LoginPantalla(repositorio: autenticacion),
        ),
      ),
    );
  }
}
