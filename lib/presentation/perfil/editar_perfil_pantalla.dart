import 'package:flutter/material.dart';

import '../../domain/model/perfil.dart';
import '../../domain/repository/perfil_repositorio.dart';

class EditarPerfilPantalla extends StatefulWidget {
  final PerfilRepositorio perfiles;
  final Perfil perfil;

  const EditarPerfilPantalla({
    super.key,
    required this.perfiles,
    required this.perfil,
  });

  @override
  State<EditarPerfilPantalla> createState() => _EditarPerfilPantallaState();
}

class _EditarPerfilPantallaState extends State<EditarPerfilPantalla> {
  late final _nombre = TextEditingController(text: widget.perfil.nombre);
  late final _pais = TextEditingController(text: widget.perfil.pais);
  late final _provincia = TextEditingController(text: widget.perfil.provincia);
  late final _localidad = TextEditingController(text: widget.perfil.localidad);
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _pais.dispose();
    _provincia.dispose();
    _localidad.dispose();
    super.dispose();
  }

  // RF2 - Perfil: se guardan los datos editados y se vuelve al Perfil para que los muestre
  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty) {
      setState(() => _error = 'Ingresá tu nombre');
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await widget.perfiles.guardar(
        Perfil(
          nombre: _nombre.text.trim(),
          pais: _pais.text.trim(),
          provincia: _provincia.text.trim(),
          localidad: _localidad.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      setState(() {
        _guardando = false;
        _error = 'No se pudieron guardar los cambios';
      });
    }
  }

  Widget _campo(TextEditingController controller, String etiqueta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _campo(_nombre, 'Nombre'),
          _campo(_pais, 'País'),
          _campo(_provincia, 'Provincia'),
          _campo(_localidad, 'Localidad'),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
