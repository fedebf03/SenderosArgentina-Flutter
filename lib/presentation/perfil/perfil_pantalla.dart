import 'package:flutter/material.dart';

import '../../domain/model/perfil.dart';
import '../../domain/model/preferencias.dart';
import '../../domain/repository/autenticacion_repositorio.dart';
import '../../domain/repository/perfil_repositorio.dart';
import '../../domain/repository/preferencias_repositorio.dart';
import 'editar_perfil_pantalla.dart';

class PerfilPantalla extends StatefulWidget {
  final AutenticacionRepositorio autenticacion;
  final PerfilRepositorio perfiles;
  final PreferenciasRepositorio preferencias;
  final ValueNotifier<ModoTema> modoTema;

  const PerfilPantalla({
    super.key,
    required this.autenticacion,
    required this.perfiles,
    required this.preferencias,
    required this.modoTema,
  });

  @override
  State<PerfilPantalla> createState() => _PerfilPantallaState();
}

class _PerfilPantallaState extends State<PerfilPantalla> {
  late Future<Perfil> _perfil = widget.perfiles.obtener();

  Future<void> _editarPerfil(Perfil perfil) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditarPerfilPantalla(perfiles: widget.perfiles, perfil: perfil),
      ),
    );
    if (guardado == true) {
      setState(() {
        _perfil = widget.perfiles.obtener();
      });
    }
  }

  Future<void> _cambiarModoTema(ModoTema modo) async {
    widget.modoTema.value = modo;
    await widget.preferencias.guardarModoTema(modo);
  }

  Future<void> _cerrarSesion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Querés cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado == true) await widget.autenticacion.cerrarSesion();
  }

  // RF2 - Perfil: mostramos la cuenta con la que se inició sesión y los datos que el usuario cargó en Firestore
  @override
  Widget build(BuildContext context) {
    final usuario = widget.autenticacion.usuarioActual();
    final correo = usuario?.correo ?? '';
    final fotoUrl = usuario?.fotoUrl ?? '';
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Perfil>(
          future: _perfil,
          builder: (context, snapshot) {
            final perfil = snapshot.data ?? Perfil();
            final nombre = perfil.nombre.isNotEmpty
                ? perfil.nombre
                : usuario?.nombre ?? '';
            final ubicacion = [
              perfil.localidad,
              perfil.provincia,
              perfil.pais,
            ].where((texto) => texto.isNotEmpty).join(', ');

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: fotoUrl.isNotEmpty
                        ? NetworkImage(fotoUrl)
                        : null,
                    child: fotoUrl.isEmpty
                        ? Text(
                            (nombre.isNotEmpty ? nombre : correo)
                                .characters
                                .first
                                .toUpperCase(),
                            style: tema.textTheme.headlineMedium,
                          )
                        : null,
                  ),
                ),
                if (nombre.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    nombre,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                SizedBox(height: nombre.isNotEmpty ? 4 : 16),
                for (final dato in [correo, ubicacion])
                  if (dato.isNotEmpty)
                    Text(
                      dato,
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => _editarPerfil(
                    Perfil(
                      nombre: nombre,
                      pais: perfil.pais,
                      provincia: perfil.provincia,
                      localidad: perfil.localidad,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar perfil'),
                ),
                const SizedBox(height: 32),
                Text('Preferencias', style: tema.textTheme.titleMedium),
                const SizedBox(height: 12),
                ValueListenableBuilder<ModoTema>(
                  valueListenable: widget.modoTema,
                  builder: (context, modo, _) => SegmentedButton<ModoTema>(
                    segments: const [
                      ButtonSegment(
                        value: ModoTema.sistema,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('Sistema'),
                      ),
                      ButtonSegment(
                        value: ModoTema.claro,
                        icon: Icon(Icons.light_mode),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ModoTema.oscuro,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Oscuro'),
                      ),
                    ],
                    selected: {modo},
                    onSelectionChanged: (elegido) =>
                        _cambiarModoTema(elegido.first),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _cerrarSesion,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tema.colorScheme.error,
                    side: BorderSide(color: tema.colorScheme.error),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
