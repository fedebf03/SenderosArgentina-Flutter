import 'package:flutter/material.dart';

import '../../domain/model/sendero.dart';
import '../../domain/repository/notificacion_repositorio.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../../domain/repository/ubicacion_repositorio.dart';
import 'mapa_ubicacion.dart';

class FormularioSenderoPantalla extends StatefulWidget {
  final SenderoRepositorio senderos;
  final UbicacionRepositorio ubicacion;
  final NotificacionRepositorio notificaciones;
  final Sendero? sendero;

  const FormularioSenderoPantalla({
    super.key,
    required this.senderos,
    required this.ubicacion,
    required this.notificaciones,
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
  late double? _latitud = widget.sendero?.latitud;
  late double? _longitud = widget.sendero?.longitud;
  bool _guardando = false;
  bool _ubicando = false;

  // RF5 - Geolocalización: el inicio del sendero se guarda con la ubicación actual del usuario
  Future<void> _usarMiUbicacion() async {
    setState(() => _ubicando = true);
    try {
      final actual = await widget.ubicacion.ubicacionActual();
      setState(() {
        _latitud = actual.latitud;
        _longitud = actual.longitud;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos obtener tu ubicación')),
      );
    } finally {
      if (mounted) setState(() => _ubicando = false);
    }
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
  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await widget.senderos.guardarSendero(
        Sendero(
          id: widget.sendero?.id ?? '',
          nombre: _nombre.text.trim(),
          region: _region.text.trim(),
          distanciaKilometros: _kilometros(_distancia.text)!,
          dificultad: _dificultad,
          descripcion: _descripcion.text.trim(),
          latitud: _latitud,
          longitud: _longitud,
        ),
      );
      // Si falla el aviso el sendero ya quedó guardado, así que no se muestra error
      widget.notificaciones
          .avisar('Sendero guardado', _nombre.text.trim())
          .ignore();
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
      body: Form(
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
                DropdownMenuItem(value: Dificultad.media, child: Text('Media')),
                DropdownMenuItem(value: Dificultad.alta, child: Text('Alta')),
              ],
              onChanged: (valor) => _dificultad = valor ?? _dificultad,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcion,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            if (_latitud != null && _longitud != null)
              MapaUbicacion(latitud: _latitud!, longitud: _longitud!),
            OutlinedButton.icon(
              onPressed: _ubicando ? null : _usarMiUbicacion,
              icon: const Icon(Icons.my_location),
              label: Text(_ubicando ? 'Ubicando…' : 'Usar mi ubicación'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando…' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
