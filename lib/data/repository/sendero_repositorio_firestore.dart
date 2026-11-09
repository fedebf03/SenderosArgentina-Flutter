import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/model/punto.dart';
import '../../domain/model/sendero.dart';
import '../../domain/repository/sendero_repositorio.dart';

class SenderoRepositorioFirestore implements SenderoRepositorio {
  // RF2 - Explorar: traemos los senderos que publicaron todos los usuarios, del más nuevo al más viejo
  @override
  Stream<List<Sendero>> senderosPublicos() {
    return FirebaseFirestore.instance
        .collection('senderosPublicos')
        .orderBy('fechaPublicacion', descending: true)
        .snapshots()
        .map(
          (consulta) => consulta.docs.map((documento) {
            final publicado = documento.data();
            return _sendero(
              documento.id,
              publicado['sendero'] ?? {},
              autor: publicado['nombreAutor'] ?? '',
            );
          }).toList(),
        );
  }

  // RF2 - Publicar: el sendero se copia entero a los públicos con el mismo id que en Mis senderos
  @override
  Future<void> publicar(String idSendero) async {
    final usuario = FirebaseAuth.instance.currentUser!;
    final propio = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('senderos')
        .doc(idSendero)
        .get();
    final nombre = usuario.displayName ?? '';
    await FirebaseFirestore.instance
        .collection('senderosPublicos')
        .doc(idSendero)
        .set({
          'idAutor': usuario.uid,
          'nombreAutor': nombre.isNotEmpty
              ? nombre
              : usuario.email!.split('@').first,
          'fechaPublicacion': DateTime.now().millisecondsSinceEpoch,
          'sendero': propio.data(),
        });
  }

  @override
  Future<void> despublicar(String idSendero) => FirebaseFirestore.instance
      .collection('senderosPublicos')
      .doc(idSendero)
      .delete();

  // RF4 - Eliminar: el sendero queda marcado como eliminado y, si era público, deja de serlo
  @override
  Future<void> eliminarSendero(String idSendero) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No hay sesión iniciada');
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('senderos')
        .doc(idSendero)
        .update({
          'eliminado': true,
          'fechaModificacion': DateTime.now().millisecondsSinceEpoch,
        });
    // Las reglas no dejan borrar un público que no existe, por eso se revisa antes
    final publico = FirebaseFirestore.instance
        .collection('senderosPublicos')
        .doc(idSendero);
    if ((await publico.get()).exists) await publico.delete();
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
              // Los senderos borrados quedan marcados como eliminados y no se muestran
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
    // Con merge se conservan los campos que el formulario no edita
    await documento.set({
      'id': documento.id,
      'nombre': sendero.nombre,
      'region': sendero.region,
      'distanciaKilometros': sendero.distanciaKilometros,
      'dificultad': sendero.dificultad.name.toUpperCase(),
      'descripcion': sendero.descripcion,
      'foto': sendero.foto,
      'latitudInicio': sendero.latitud,
      'longitudInicio': sendero.longitud,
      'recorrido': sendero.recorrido
          .map(
            (punto) => {'latitud': punto.latitud, 'longitud': punto.longitud},
          )
          .toList(),
      'eliminado': false,
      'fechaModificacion': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  Sendero _sendero(String id, Map sendero, {String autor = ''}) {
    // Si el sendero no tiene inicio guardado, se usa el primer punto del trazado
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
      recorrido: recorrido
          .map(
            (punto) => Punto(
              (punto['latitud'] as num).toDouble(),
              (punto['longitud'] as num).toDouble(),
            ),
          )
          .toList(),
      idOrigen: sendero['idOrigen'] ?? '',
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
