import 'package:flutter/material.dart';

import '../../domain/model/sendero.dart';
import '../../domain/repository/sendero_repositorio.dart';
import 'datos_sendero.dart';
import 'detalle_sendero_pantalla.dart';

class ExplorarPantalla extends StatefulWidget {
  final SenderoRepositorio senderos;

  const ExplorarPantalla({super.key, required this.senderos});

  @override
  State<ExplorarPantalla> createState() => _ExplorarPantallaState();
}

class _ExplorarPantallaState extends State<ExplorarPantalla> {
  late final Future<List<Sendero>> _senderos = widget.senderos
      .obtenerSenderos();
  final _buscador = TextEditingController();

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  // RF2 - Explorar: la búsqueda filtra por nombre o región sin distinguir mayúsculas
  List<Sendero> _filtrar(List<Sendero> senderos) {
    final texto = _buscador.text.trim().toLowerCase();
    return senderos
        .where(
          (sendero) =>
              sendero.nombre.toLowerCase().contains(texto) ||
              sendero.region.toLowerCase().contains(texto),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
        Expanded(
          child: FutureBuilder<List<Sendero>>(
            future: _senderos,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('No pudimos cargar los senderos públicos'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Todavía no hay senderos publicados'),
                );
              }
              final senderos = _filtrar(snapshot.data!);
              if (senderos.isEmpty) {
                return const Center(child: Text('No se encontraron senderos'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: senderos.length,
                itemBuilder: (context, indice) =>
                    TarjetaSendero(sendero: senderos[indice]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TarjetaSendero extends StatelessWidget {
  final Sendero sendero;

  const TarjetaSendero({super.key, required this.sendero});

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
            builder: (_) => DetalleSenderoPantalla(sendero: sendero),
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
