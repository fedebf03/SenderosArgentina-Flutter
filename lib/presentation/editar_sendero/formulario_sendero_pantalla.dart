import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/model/punto.dart';
import '../../domain/model/sendero.dart';
import '../../domain/repository/foto_repositorio.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../../domain/repository/ubicacion_repositorio.dart';
import '../explorar/mapa_sendero.dart';

class FormularioSenderoPantalla extends StatefulWidget {
  final SenderoRepositorio senderos;
  final UbicacionRepositorio ubicacion;
  final FotoRepositorio fotos;
  final Sendero? sendero;

  const FormularioSenderoPantalla({
    super.key,
    required this.senderos,
    required this.ubicacion,
    required this.fotos,
    this.sendero,
  });

  @override
  State<FormularioSenderoPantalla> createState() =>
      _FormularioSenderoPantallaState();
}

class _FormularioSenderoPantallaState extends State<FormularioSenderoPantalla> {
  final _formulario = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.sendero?.nombre);
  late final _region = TextEditingController(text: widget.sendero?.region);
  late final _distancia = TextEditingController(
    text: widget.sendero?.distanciaKilometros.toString(),
  );
  late final _descripcion = TextEditingController(
    text: widget.sendero?.descripcion,
  );
  late Dificultad _dificultad = widget.sendero?.dificultad ?? Dificultad.baja;
  late Punto? _inicio = widget.sendero?.latitud == null
      ? null
      : Punto(widget.sendero!.latitud!, widget.sendero!.longitud!);
  late final List<Punto> _recorrido = [...?widget.sendero?.recorrido];
  late final String _fotoGuardada = widget.sendero?.foto ?? '';
  String? _fotoNueva;
  bool _mostrarFaltantes = false;
  bool _guardando = false;
  bool _ubicando = false;

  // RF5 - Geolocalización: el inicio del sendero se guarda con la ubicación actual del usuario
  Future<void> _usarMiUbicacion() async {
    setState(() => _ubicando = true);
    try {
      final actual = await widget.ubicacion.ubicacionActual();
      setState(() => _inicio = Punto(actual.latitud, actual.longitud));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos obtener tu ubicación')),
      );
    } finally {
      if (mounted) setState(() => _ubicando = false);
    }
  }

  // RF4 - Recorrido: cada toque en el mapa suma un punto y la distancia se recalcula
  void _cambiarRecorrido(VoidCallback cambio) {
    setState(cambio);
    if (_recorrido.length > 1) {
      _distancia.text = kilometrosRecorridos(_recorrido).toStringAsFixed(2);
    }
  }

  // RF6 - Cámara: la foto se saca en el momento o se elige de la galería
  Future<void> _elegirFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origen == null) return;
    final foto = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (foto != null) setState(() => _fotoNueva = foto.path);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _region.dispose();
    _distancia.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  double? _kilometros(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  // RF4 - Crear y editar: valida el formulario y guarda el sendero en Firestore
  bool get _tieneFoto => _fotoNueva != null || _fotoGuardada.isNotEmpty;
  bool get _tieneRecorrido => _recorrido.length > 1;

  Widget _faltante(bool falta, String texto) {
    if (!_mostrarFaltantes || !falta) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        texto,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() => _mostrarFaltantes = true);
    final valido = _formulario.currentState!.validate();
    if (!valido || !_tieneFoto || !_tieneRecorrido) return;
    setState(() => _guardando = true);
    try {
      final foto = _fotoNueva == null
          ? _fotoGuardada
          : await widget.fotos.subir(_fotoNueva!);
      await widget.senderos.guardarSendero(
        Sendero(
          id: widget.sendero?.id ?? '',
          nombre: _nombre.text.trim(),
          region: _region.text.trim(),
          distanciaKilometros: _kilometros(_distancia.text)!,
          dificultad: _dificultad,
          descripcion: _descripcion.text.trim(),
          foto: foto,
          latitud: (_recorrido.firstOrNull ?? _inicio)?.latitud,
          longitud: (_recorrido.firstOrNull ?? _inicio)?.longitud,
          recorrido: _recorrido,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos guardar el sendero')),
      );
    }
  }

  String? _obligatorio(String? texto) =>
      (texto ?? '').trim().isEmpty ? 'Completá este campo' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sendero == null ? 'Nuevo sendero' : 'Editar sendero',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formulario,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _obligatorio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _region,
                decoration: const InputDecoration(labelText: 'Región'),
                validator: _obligatorio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distancia,
                decoration: const InputDecoration(labelText: 'Distancia (km)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (texto) {
                  final valor = _kilometros(texto ?? '');
                  return valor == null || valor <= 0
                      ? 'Ingresá una distancia válida'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Dificultad>(
                initialValue: _dificultad,
                decoration: const InputDecoration(labelText: 'Dificultad'),
                items: const [
                  DropdownMenuItem(value: Dificultad.baja, child: Text('Baja')),
                  DropdownMenuItem(
                    value: Dificultad.media,
                    child: Text('Media'),
                  ),
                  DropdownMenuItem(value: Dificultad.alta, child: Text('Alta')),
                ],
                onChanged: (valor) => _dificultad = valor ?? _dificultad,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 4,
                validator: _obligatorio,
              ),
              const SizedBox(height: 16),
              if (_tieneFoto) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _fotoNueva != null
                        ? Image.file(File(_fotoNueva!), height: 220)
                        : Image.network(_fotoGuardada, height: 220),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: _guardando ? null : _elegirFoto,
                icon: const Icon(Icons.add_a_photo),
                label: Text(_tieneFoto ? 'Cambiar foto' : 'Agregar foto'),
              ),
              _faltante(!_tieneFoto, 'Agregá una foto'),
              const SizedBox(height: 16),
              MapaSendero(
                inicio: _inicio,
                recorrido: _recorrido,
                alTocar: (punto) =>
                    _cambiarRecorrido(() => _recorrido.add(punto)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _ubicando ? null : _usarMiUbicacion,
                      icon: const Icon(Icons.my_location),
                      label: Text(_ubicando ? 'Ubicando…' : 'Mi ubicación'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _recorrido.isEmpty
                          ? null
                          : () => _cambiarRecorrido(_recorrido.removeLast),
                      icon: const Icon(Icons.undo),
                      label: const Text('Deshacer'),
                    ),
                  ),
                ],
              ),
              _faltante(!_tieneRecorrido, 'Marcá el recorrido en el mapa'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(_guardando ? 'Guardando…' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
