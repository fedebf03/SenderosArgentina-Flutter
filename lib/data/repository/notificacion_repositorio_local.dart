import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as zonas;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/repository/notificacion_repositorio.dart';

class NotificacionRepositorioLocal implements NotificacionRepositorio {
  static const _idRecordatorio = 1;
  static const _idRecorrido = 2;
  static const _zonaArgentina = 'America/Argentina/Buenos_Aires';
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _iniciado = false;

  // Iniciar el plugin una sola vez y pedir el permiso (Android 13 lo pide en tiempo de uso)
  Future<void> _iniciar() async {
    if (_iniciado) return;
    zonas.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_zonaArgentina));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _iniciado = true;
  }

  // Calcular el próximo aviso: hoy a la hora fijada o mañana si ya pasó
  tz.TZDateTime _proximoAviso(int hora, int minuto) {
    final ahora = tz.TZDateTime.now(tz.local);
    final hoy = tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day,
      hora,
      minuto,
    );
    return hoy.isAfter(ahora) ? hoy : hoy.add(const Duration(days: 1));
  }

  // RF7 - Notificaciones: recordatorio local todos los días a la hora elegida (hora argentina)
  @override
  Future<void> activarRecordatorio(int hora, int minuto) async {
    await _iniciar();
    await _plugin.zonedSchedule(
      id: _idRecordatorio,
      title: '¿Salimos a caminar?',
      body: 'Hay senderos esperándote en SenderosArgentina',
      scheduledDate: _proximoAviso(hora, minuto),
      matchDateTimeComponents: DateTimeComponents.time,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios',
          'Recordatorios de senderos',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // Mostrar un aviso inmediato (inicio y fin de un recorrido)
  @override
  Future<void> avisar(String titulo, String texto) async {
    await _iniciar();
    await _plugin.show(
      id: _idRecorrido,
      title: titulo,
      body: texto,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('recorridos', 'Recorridos'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Cancelar el recordatorio diario programado
  @override
  Future<void> desactivarRecordatorio() async {
    await _iniciar();
    await _plugin.cancel(id: _idRecordatorio);
  }
}
