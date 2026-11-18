import 'package:flutter/material.dart';

import '../../domain/model/usuario.dart';
import '../../domain/repository/autenticacion_repositorio.dart';
import 'registro_pantalla.dart';

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
    if (!correoValido(correo)) {
      setState(() => _error = 'El correo no tiene un formato válido');
      return;
    }
    await _entrar(() => widget.repositorio.iniciarSesion(correo, clave));
  }

  Future<void> _entrar(Future<void> Function() inicioDeSesion) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await inicioDeSesion();
    } on ErrorAutenticacion catch (e) {
      setState(() {
        _cargando = false;
        _error = e.mensaje;
      });
    }
  }

  Future<void> _recuperarClave() async {
    var correo = _correoController.text.trim();
    final enviar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Te enviamos un enlace para que elijas una contraseña nueva.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: correo,
              onChanged: (texto) => correo = texto.trim(),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );
    if (enviar != true || !mounted) return;

    var mensaje = 'Revisá tu correo para elegir una contraseña nueva';
    if (!correoValido(correo)) {
      mensaje = 'El correo no tiene un formato válido';
    } else {
      try {
        await widget.repositorio.enviarCorreoRecuperacion(correo);
      } on ErrorAutenticacion catch (e) {
        mensaje = e.mensaje;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _recuperarClave,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _cargando
                      ? null
                      : () =>
                            _entrar(widget.repositorio.iniciarSesionConGoogle),
                  icon: Image.asset('assets/logo_google.png', height: 20),
                  label: const Text('Continuar con Google'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tenés cuenta?'),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegistroPantalla(repositorio: widget.repositorio),
                        ),
                      ),
                      child: const Text('Registrate'),
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
