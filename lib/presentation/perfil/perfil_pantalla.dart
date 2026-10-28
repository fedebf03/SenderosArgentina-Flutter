import 'package:flutter/material.dart';

import '../../domain/repository/autenticacion_repositorio.dart';

class PerfilPantalla extends StatelessWidget {
  final AutenticacionRepositorio autenticacion;

  const PerfilPantalla({super.key, required this.autenticacion});

  Future<void> _cerrarSesion(BuildContext context) async {
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
    if (confirmado == true) await autenticacion.cerrarSesion();
  }

  // RF2 - Perfil: mostramos la foto, el nombre y el correo de la cuenta con la que se inició sesión
  @override
  Widget build(BuildContext context) {
    final usuario = autenticacion.usuarioActual();
    final nombre = usuario?.nombre ?? '';
    final correo = usuario?.correo ?? '';
    final fotoUrl = usuario?.fotoUrl ?? '';
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
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
                        (nombre.isNotEmpty ? nombre : correo).characters.first
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
            Text(
              correo,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _cerrarSesion(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: tema.colorScheme.error,
                side: BorderSide(color: tema.colorScheme.error),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
