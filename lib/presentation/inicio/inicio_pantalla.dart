import 'package:flutter/material.dart';

import '../../domain/repository/autenticacion_repositorio.dart';
import '../../domain/repository/perfil_repositorio.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../explorar/explorar_pantalla.dart';
import '../mis_senderos/mis_senderos_pantalla.dart';
import '../perfil/perfil_pantalla.dart';

class InicioPantalla extends StatefulWidget {
  final AutenticacionRepositorio autenticacion;
  final PerfilRepositorio perfiles;
  final SenderoRepositorio senderos;

  const InicioPantalla({
    super.key,
    required this.autenticacion,
    required this.perfiles,
    required this.senderos,
  });

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
      body: switch (_seccion) {
        0 => ExplorarPantalla(senderos: widget.senderos),
        1 => MisSenderosPantalla(senderos: widget.senderos),
        _ => PerfilPantalla(
          autenticacion: widget.autenticacion,
          perfiles: widget.perfiles,
        ),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (indice) => setState(() => _seccion = indice),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explorar'),
          NavigationDestination(
            icon: Icon(Icons.hiking),
            label: 'Mis senderos',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
