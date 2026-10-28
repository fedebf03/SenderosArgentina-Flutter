import 'package:flutter/material.dart';

import '../explorar/explorar_pantalla.dart';
import '../perfil/perfil_pantalla.dart';

class InicioPantalla extends StatefulWidget {
  const InicioPantalla({super.key});

  @override
  State<InicioPantalla> createState() => _InicioPantallaState();
}

class _InicioPantallaState extends State<InicioPantalla> {
  int _seccion = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo_senderos.png', height: 32),
            const SizedBox(width: 8),
            const Text('SenderosArgentina'),
          ],
        ),
      ),
      body: _seccion == 0 ? const ExplorarPantalla() : const PerfilPantalla(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (indice) => setState(() => _seccion = indice),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
