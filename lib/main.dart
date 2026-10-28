import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/repository/autenticacion_repositorio_firebase.dart';
import 'presentation/auth/login_pantalla.dart';
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
    return MaterialApp(
      title: 'Senderos Argentina',
      debugShowCheckedModeBanner: false,
      theme: temaSenderos,
      home: LoginPantalla(repositorio: AutenticacionRepositorioFirebase()),
    );
  }
}
