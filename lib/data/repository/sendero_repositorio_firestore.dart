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

  // RF4 - Crear y editar: sin id se crea un documento nuevo, con id se actualiza el existente
  @override
  Future<void> guardarSendero(Sendero sendero) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No hay sesión iniciada');
    final coleccion = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('senderos');
    final documento = sendero.id.isEmpty
        ? coleccion.doc()
        : coleccion.doc(sendero.id);
    // Con merge no se pierden los campos que solo usa la otra app, como el trazado
    await documento.set({
      'id': documento.id,
      'nombre': sendero.nombre,
      'region': sendero.region,
      'distanciaKilometros': sendero.distanciaKilometros,
      'dificultad': sendero.dificultad.name.toUpperCase(),
      'descripcion': sendero.descripcion,
      'latitudInicio': sendero.latitud,
      'longitudInicio': sendero.longitud,
      'eliminado': false,
      'fechaModificacion': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  Sendero _sendero(String id, Map sendero, {String autor = ''}) {
    // Los senderos creados en la otra app no tienen inicio guardado, se usa el primer punto del trazado
    final List recorrido = sendero['recorrido'] ?? [];
    final primerPunto = recorrido.isEmpty ? {} : recorrido.first;
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
      latitud: (sendero['latitudInicio'] ?? primerPunto['latitud'])?.toDouble(),
      longitud: (sendero['longitudInicio'] ?? primerPunto['longitud'])
          ?.toDouble(),
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
