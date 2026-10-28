import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: Scaffold(appBar: AppBar(title: const Text('Senderos Argentina'))),
    );
  }
}
