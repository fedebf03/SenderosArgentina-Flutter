import 'package:flutter/material.dart';

import '../../domain/model/usuario.dart';
import '../../domain/repository/autenticacion_repositorio.dart';

class RegistroPantalla extends StatefulWidget {
  final AutenticacionRepositorio repositorio;

  const RegistroPantalla({super.key, required this.repositorio});

  @override
  State<RegistroPantalla> createState() => _RegistroPantallaState();
}

class _RegistroPantallaState extends State<RegistroPantalla> {
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  final _confirmacionController = TextEditingController();
  bool _cargando = false;
  bool _claveVisible = false;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    _confirmacionController.dispose();
    super.dispose();
  }

  // RF1 - Registro: se validan los datos antes de crear la cuenta y, si sale bien, se entra directo al inicio
  Future<void> _registrarse() async {
    final correo = _correoController.text.trim();
    final clave = _claveController.text;
    if (!correoValido(correo)) {
      setState(() => _error = 'El correo no tiene un formato válido');
      return;
    }
    if (clave.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (clave != _confirmacionController.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await widget.repositorio.registrar(correo, clave);
      if (!mounted) return;
      Navigator.pop(context);
    } on ErrorAutenticacion catch (e) {
      setState(() {
        _cargando = false;
        _error = e.mensaje;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/logo_senderos.png', height: 120),
                const SizedBox(height: 8),
                Text(
                  'Crear cuenta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _claveController,
                  obscureText: !_claveVisible,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _claveVisible
                          ? 'Ocultar contraseña'
                          : 'Mostrar contraseña',
                      icon: Icon(
                        _claveVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _claveVisible = !_claveVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmacionController,
                  obscureText: !_claveVisible,
                  decoration: const InputDecoration(
                    labelText: 'Repetir contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _cargando ? null : _registrarse,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tenés cuenta?'),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Iniciá sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
