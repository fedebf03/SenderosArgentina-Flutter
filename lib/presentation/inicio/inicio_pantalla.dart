import 'package:flutter/material.dart';

import '../../domain/model/preferencias.dart';
import '../../domain/repository/autenticacion_repositorio.dart';
import '../../domain/repository/foto_repositorio.dart';
import '../../domain/repository/notificacion_repositorio.dart';
import '../../domain/repository/perfil_repositorio.dart';
import '../../domain/repository/preferencias_repositorio.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../../domain/repository/sensores_repositorio.dart';
import '../../domain/repository/ubicacion_repositorio.dart';
import '../explorar/explorar_pantalla.dart';
import '../perfil/perfil_pantalla.dart';

class InicioPantalla extends StatefulWidget {
  final AutenticacionRepositorio autenticacion;
  final PerfilRepositorio perfiles;
  final SenderoRepositorio senderos;
  final UbicacionRepositorio ubicacion;
  final FotoRepositorio fotos;
  final SensoresRepositorio sensores;
  final PreferenciasRepositorio preferencias;
  final ValueNotifier<ModoTema> modoTema;
  final NotificacionRepositorio notificaciones;

  const InicioPantalla({
    super.key,
    required this.autenticacion,
    required this.perfiles,
    required this.senderos,
    required this.ubicacion,
    required this.fotos,
    required this.sensores,
    required this.preferencias,
    required this.modoTema,
    required this.notificaciones,
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
        0 => ExplorarPantalla(
          senderos: widget.senderos,
          ubicacion: widget.ubicacion,
          fotos: widget.fotos,
          sensores: widget.sensores,
          notificaciones: widget.notificaciones,
        ),
        _ => PerfilPantalla(
          autenticacion: widget.autenticacion,
          perfiles: widget.perfiles,
          preferencias: widget.preferencias,
          modoTema: widget.modoTema,
        ),
      },
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
