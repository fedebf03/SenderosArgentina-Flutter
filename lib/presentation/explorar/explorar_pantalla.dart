import 'package:flutter/material.dart';

import '../../domain/model/punto.dart';
import '../../domain/model/sendero.dart';
import '../../domain/repository/foto_repositorio.dart';
import '../../domain/repository/sendero_repositorio.dart';
import '../../domain/repository/notificacion_repositorio.dart';
import '../../domain/repository/sensores_repositorio.dart';
import '../../domain/repository/ubicacion_repositorio.dart';
import '../editar_sendero/formulario_sendero_pantalla.dart';
import 'datos_sendero.dart';
import 'detalle_sendero_pantalla.dart';

class ExplorarPantalla extends StatefulWidget {
  final SenderoRepositorio senderos;
  final UbicacionRepositorio ubicacion;
  final FotoRepositorio fotos;
  final SensoresRepositorio sensores;
  final NotificacionRepositorio notificaciones;

  const ExplorarPantalla({
    super.key,
    required this.senderos,
    required this.ubicacion,
    required this.fotos,
    required this.sensores,
    required this.notificaciones,
  });

  @override
  State<ExplorarPantalla> createState() => _ExplorarPantallaState();
}

class _ExplorarPantallaState extends State<ExplorarPantalla> {
  late final Stream<List<Sendero>> _publicos = widget.senderos
      .senderosPublicos();
  late final Stream<List<Sendero>> _mios = widget.senderos.misSenderos();
  final _buscador = TextEditingController();
  final Set<Dificultad> _dificultades = {};
  Punto? _miUbicacion;
  bool _soloMios = false;

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  List<Sendero> _filtrar(List<Sendero> senderos) =>
      filtrarSenderos(senderos, _buscador.text, _dificultades);

  Future<void> _ordenarPorCercania(bool activado) async {
    if (!activado) return setState(() => _miUbicacion = null);
    try {
      final actual = await widget.ubicacion.ubicacionActual();
      setState(() => _miUbicacion = Punto(actual.latitud, actual.longitud));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos obtener tu ubicación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo sendero',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioSenderoPantalla(
              senderos: widget.senderos,
              ubicacion: widget.ubicacion,
              fotos: widget.fotos,
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _buscador,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar senderos',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _buscador.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_buscador.clear),
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Mis senderos'),
                selected: _soloMios,
                onSelected: (activado) => setState(() => _soloMios = activado),
              ),
              FilterChip(
                avatar: const Icon(Icons.near_me),
                label: const Text('Más cercanos'),
                selected: _miUbicacion != null,
                onSelected: _ordenarPorCercania,
              ),
              for (final dificultad in Dificultad.values)
                FilterChip(
                  label: Text(IndicadorDificultad.textos[dificultad]!),
                  selected: _dificultades.contains(dificultad),
                  onSelected: (activado) => setState(
                    () => activado
                        ? _dificultades.add(dificultad)
                        : _dificultades.remove(dificultad),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Sendero>>(
            stream: _publicos,
            builder: (context, publicos) => StreamBuilder<List<Sendero>>(
              stream: _mios,
              builder: (context, mios) {
                if (publicos.hasError) {
                  return const Center(
                    child: Text('No pudimos cargar los senderos'),
                  );
                }
                if (!publicos.hasData || !mios.hasData && !mios.hasError) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _lista(publicos.data!, mios.data ?? []);
              },
            ),
          ),
        ),
      ],
    );
  }

  // RF2 - Explorar: primero los senderos públicos y al final los propios, que se pueden editar
  Widget _lista(List<Sendero> publicos, List<Sendero> mios) {
    if (publicos.isEmpty && mios.isEmpty) {
      return const Center(child: Text('Todavía no hay senderos'));
    }
    final propios = mios.where((sendero) => sendero.idOrigen.isEmpty).toList();
    final ajenos = senderosAjenos(publicos, propios);
    final todos = [if (!_soloMios) ..._filtrar(ajenos), ..._filtrar(propios)];
    if (todos.isEmpty) {
      return const Center(child: Text('No se encontraron senderos'));
    }
    if (_miUbicacion != null) {
      ordenarPorCercania(todos, _miUbicacion!);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        for (final sendero in todos)
          TarjetaSendero(
            sendero: sendero,
            ubicacion: widget.ubicacion,
            sensores: widget.sensores,
            notificaciones: widget.notificaciones,
            senderos: propios.contains(sendero) ? widget.senderos : null,
            fotos: propios.contains(sendero) ? widget.fotos : null,
          ),
      ],
    );
  }
}

class TarjetaSendero extends StatelessWidget {
  final Sendero sendero;
  final UbicacionRepositorio ubicacion;
  final SensoresRepositorio sensores;
  final NotificacionRepositorio notificaciones;
  // Solo llegan en los senderos propios, para poder editar desde el detalle
  final SenderoRepositorio? senderos;
  final FotoRepositorio? fotos;

  const TarjetaSendero({
    super.key,
    required this.sendero,
    required this.ubicacion,
    required this.sensores,
    required this.notificaciones,
    this.senderos,
    this.fotos,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final gris = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleSenderoPantalla(
              sendero: sendero,
              ubicacion: ubicacion,
              sensores: sensores,
              notificaciones: notificaciones,
              senderos: senderos,
              fotos: fotos,
            ),
          ),
        ),
        child: Row(
          children: [
            _Foto(url: sendero.foto),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sendero.nombre,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(sendero.region, style: gris),
                    if (sendero.autor.isNotEmpty)
                      Text('Por ${sendero.autor}', style: gris),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          kilometros(sendero.distanciaKilometros),
                          style: gris,
                        ),
                        if (sendero.duracionEstimada.isNotEmpty)
                          Text(' · ${sendero.duracionEstimada}', style: gris),
                        const Spacer(),
                        IndicadorDificultad(dificultad: sendero.dificultad),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  final String url;

  const _Foto({required this.url});

  @override
  Widget build(BuildContext context) {
    final sinFoto = Container(
      width: 96,
      height: 110,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Icon(Icons.terrain),
    );
    if (url.isEmpty) return sinFoto;
    return Image.network(
      url,
      width: 96,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => sinFoto,
    );
  }
}
