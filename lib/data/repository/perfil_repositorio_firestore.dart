import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/model/perfil.dart';
import '../../domain/repository/perfil_repositorio.dart';

class PerfilRepositorioFirestore implements PerfilRepositorio {
  DocumentReference<Map<String, dynamic>> get _documento => FirebaseFirestore
      .instance
      .collection('usuarios')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  @override
  Future<Perfil> obtener() async {
    final datos = (await _documento.get()).data()?['perfil'] ?? {};
    return Perfil(
      nombre: datos['nombre'] ?? '',
      pais: datos['pais'] ?? '',
      provincia: datos['provincia'] ?? '',
      localidad: datos['localidad'] ?? '',
    );
  }

  // RF2 - Perfil: se guarda con merge dentro de "perfil" para no pisar la foto ni el resto del documento del usuario
  @override
  Future<void> guardar(Perfil perfil) {
    return _documento.set({
      'perfil': {
        'nombre': perfil.nombre,
        'pais': perfil.pais,
        'provincia': perfil.provincia,
        'localidad': perfil.localidad,
      },
    }, SetOptions(merge: true));
  }
}
