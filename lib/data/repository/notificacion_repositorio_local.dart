import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/repository/notificacion_repositorio.dart';

class NotificacionRepositorioLocal implements NotificacionRepositorio {
  static const _idRecorrido = 1;
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _iniciado;
  bool _recorridoVisible = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> _iniciar() => _iniciado ??= _prepararPlugin();

  Future<void> _prepararPlugin() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _android?.requestNotificationsPermission();
  }

  // RF7 - Notificaciones: mientras dura el recorrido queda una notificación fija con el tiempo,
  // los km y los pasos. Como es un servicio en primer plano, el GPS sigue con la pantalla apagada
  @override
  Future<void> mostrarRecorrido(
    String titulo,
    String texto,
    DateTime inicio,
  ) async {
    await _iniciar();
    final detalles = AndroidNotificationDetails(
      'recorrido_en_curso',
      'Recorrido en curso',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      usesChronometer: true,
      when: inicio.millisecondsSinceEpoch,
    );
    if (_recorridoVisible) {
      await _plugin.show(
        id: _idRecorrido,
        title: titulo,
        body: texto,
        notificationDetails: NotificationDetails(android: detalles),
      );
      return;
    }
    _recorridoVisible = true;
    await _android?.startForegroundService(
      id: _idRecorrido,
      title: titulo,
      body: texto,
      notificationDetails: detalles,
      foregroundServiceTypes: {
        AndroidServiceForegroundType.foregroundServiceTypeLocation,
      },
    );
  }

  @override
  Future<void> cerrarRecorrido() async {
    _recorridoVisible = false;
    await _android?.stopForegroundService();
  }
}
