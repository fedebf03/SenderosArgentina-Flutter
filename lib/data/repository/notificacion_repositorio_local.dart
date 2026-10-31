import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/repository/notificacion_repositorio.dart';

class NotificacionRepositorioLocal implements NotificacionRepositorio {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _iniciado = false;

  // RF7 - Notificaciones: aviso local, no hace falta servidor porque lo dispara la misma app
  @override
  Future<void> avisar(String titulo, String texto) async {
    if (!_iniciado) {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      // Desde Android 13 el permiso de notificaciones se pide en tiempo de uso
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      _iniciado = true;
    }
    await _plugin.show(
      id: 0,
      title: titulo,
      body: texto,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('senderos', 'Senderos'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
