import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/model/sendero.dart';
import '../../domain/repository/sendero_repositorio.dart';

class SenderoRepositorioFirestore implements SenderoRepositorio {
  // RF2 - Explorar: traemos los senderos que publicaron todos los usuarios, del más nuevo al más viejo
  @override
  Future<List<Sendero>> obtenerSenderos() async {
    final consulta = await FirebaseFirestore.instance
        .collection('senderosPublicos')
        .orderBy('fechaPublicacion', descending: true)
        .get();
    return consulta.docs.map((documento) {
      final publicado = documento.data();
      final sendero = publicado['sendero'] ?? {};
      return Sendero(
        id: documento.id,
        nombre: sendero['nombre'] ?? '',
        region: sendero['region'] ?? '',
        distanciaKilometros: (sendero['distanciaKilometros'] ?? 0).toDouble(),
        dificultad: _dificultad(sendero['dificultad']),
        descripcion: sendero['descripcion'] ?? '',
        autor: publicado['nombreAutor'] ?? '',
        foto: sendero['foto'] ?? '',
        desnivelMetros: (sendero['desnivelMetros'] ?? 0).toInt(),
        duracionEstimada: sendero['duracionEstimada'] ?? '',
        puntoInicio: sendero['puntoInicio'] ?? '',
        mejorEpoca: sendero['mejorEpoca'] ?? '',
      );
    }).toList();
  }

  Dificultad _dificultad(String? texto) {
    switch (texto) {
      case 'ALTA':
        return Dificultad.alta;
      case 'MEDIA':
        return Dificultad.media;
      default:
        return Dificultad.baja;
    }
  }
}
