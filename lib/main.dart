import 'package:flutter/material.dart';

void main() {
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
