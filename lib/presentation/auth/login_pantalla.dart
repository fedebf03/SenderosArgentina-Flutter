import 'package:flutter/material.dart';

import '../../domain/repository/autenticacion_repositorio.dart';
import '../inicio/inicio_pantalla.dart';

class LoginPantalla extends StatefulWidget {
  final AutenticacionRepositorio repositorio;

  const LoginPantalla({super.key, required this.repositorio});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  bool _cargando = false;
  bool _claveVisible = false;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  // RF1 - Login: con los datos del formulario se pide el inicio de sesión y, si sale bien, pasamos al inicio
  Future<void> _iniciarSesion() async {
    final correo = _correoController.text.trim();
    final clave = _claveController.text;
    if (correo.isEmpty || clave.isEmpty) {
      setState(() => _error = 'Completá el correo y la contraseña');
      return;
    }
    if (!correo.contains('@') || !correo.contains('.')) {
      setState(() => _error = 'El correo no tiene un formato válido');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await widget.repositorio.iniciarSesion(correo, clave);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioPantalla()),
      );
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
                  'SenderosArgentina',
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
                  onPressed: _cargando ? null : _iniciarSesion,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
