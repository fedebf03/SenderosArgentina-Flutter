import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      return _sendero(
        documento.id,
        publicado['sendero'] ?? {},
        autor: publicado['nombreAutor'] ?? '',
      );
    }).toList();
  }

  // RF2 - Mis senderos: solo los del usuario con sesión, y la lista se actualiza sola al guardar
  @override
  Stream<List<Sendero>> misSenderos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('senderos')
        .snapshots()
        .map(
          (consulta) => consulta.docs
              // La otra app no borra el documento, lo marca como eliminado
              .where((documento) => documento.data()['eliminado'] != true)
              .map((documento) => _sendero(documento.id, documento.data()))
              .toList(),
        );
  }

  Sendero _sendero(String id, Map sendero, {String autor = ''}) {
    return Sendero(
      id: id,
      nombre: sendero['nombre'] ?? '',
      region: sendero['region'] ?? '',
      distanciaKilometros: (sendero['distanciaKilometros'] ?? 0).toDouble(),
      dificultad: _dificultad(sendero['dificultad']),
      descripcion: sendero['descripcion'] ?? '',
      autor: autor,
      foto: sendero['foto'] ?? '',
      desnivelMetros: (sendero['desnivelMetros'] ?? 0).toInt(),
      duracionEstimada: sendero['duracionEstimada'] ?? '',
      puntoInicio: sendero['puntoInicio'] ?? '',
      mejorEpoca: sendero['mejorEpoca'] ?? '',
    );
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
