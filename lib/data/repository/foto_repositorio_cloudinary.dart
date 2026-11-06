import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/repository/foto_repositorio.dart';

class FotoRepositorioCloudinary implements FotoRepositorio {
  static const _nube = 'disbfh4at';
  static const _preset = 'senderosargentina';

  // RF6 - Fotos: la foto se sube a Cloudinary y en Firestore solo queda la URL
  @override
  Future<String> subir(String rutaArchivo) async {
    final pedido =
        http.MultipartRequest(
            'POST',
            Uri.parse('https://api.cloudinary.com/v1_1/$_nube/image/upload'),
          )
          ..fields['upload_preset'] = _preset
          ..fields['folder'] = 'senderos'
          ..files.add(await http.MultipartFile.fromPath('file', rutaArchivo));
    final respuesta = await http.Response.fromStream(await pedido.send());
    if (respuesta.statusCode != 200) {
      throw Exception('Cloudinary rechazó la foto');
    }
    return jsonDecode(respuesta.body)['secure_url'];
  }
}
