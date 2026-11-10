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
import 'presentation/auth/login_pantalla.dart';
import 'presentation/inicio/inicio_pantalla.dart';
import 'presentation/tema.dart';

Future<void> main() async {
  // Firebase tiene que estar listo antes de dibujar la primera pantalla
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Leer las preferencias antes de dibujar para no mostrar un tema y cambiarlo enseguida
  final preferencias = PreferenciasRepositorioLocal();
  final iniciales = await preferencias.obtener();
  runApp(
    SenderosApp(
      preferencias: preferencias,
      estadoPreferencias: ValueNotifier(iniciales),
    ),
  );
}

class SenderosApp extends StatelessWidget {
  final PreferenciasRepositorio preferencias;
  final ValueNotifier<Preferencias> estadoPreferencias;

  const SenderosApp({
    super.key,
    required this.preferencias,
    required this.estadoPreferencias,
  });

  // Convertir el modo elegido por el usuario al modo de tema de Flutter
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
    // Modo oscuro: la app se vuelve a pintar sola cuando cambia la preferencia
    return ValueListenableBuilder<Preferencias>(
      valueListenable: estadoPreferencias,
      builder: (context, actuales, _) => MaterialApp(
        title: 'Senderos Argentina',
        debugShowCheckedModeBanner: false,
        theme: temaSenderos,
        darkTheme: temaSenderosOscuro,
        themeMode: _modoFlutter(actuales.modoTema),
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
                  estadoPreferencias: estadoPreferencias,
                  notificaciones: notificaciones,
                )
              : LoginPantalla(repositorio: autenticacion),
        ),
      ),
    );
  }
}
