import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'package:timezone/timezone.dart' as tz;



class NotificationService {

  NotificationService._();

  static final NotificationService instance = NotificationService._();



  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;



  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>

      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();



  Future<void> initialize() async {

    if (_initialized) return;



    tz.initializeTimeZones();



    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(

      android: androidSettings,

      iOS: iosSettings,

    );



    await _plugin.initialize(settings);



    final android = _androidPlugin;

    if (android != null) {

      await android.createNotificationChannel(

        const AndroidNotificationChannel(

          'note_reminders',

          'Note Reminders',

          description: 'Reminders for NoteVault',

          importance: Importance.high,

        ),

      );

    }



    _initialized = true;

  }



  Future<bool> requestPermissions() async {

    await initialize();



    final android = _androidPlugin;

    if (android == null) return true;



    final notificationsGranted = await android.requestNotificationsPermission();

    await android.requestExactAlarmsPermission();

    return notificationsGranted ?? true;

  }



  Future<void> scheduleNoteReminder({

    required String noteId,

    required String title,

    required String body,

    required DateTime reminderAt,

  }) async {

    if (!_initialized) return;



    final id = noteId.hashCode;

    await _plugin.zonedSchedule(

      id,

      title,

      body,

      tz.TZDateTime.from(reminderAt, tz.local),

      const NotificationDetails(

        android: AndroidNotificationDetails(

          'note_reminders',

          'Note Reminders',

          channelDescription: 'Reminders for NoteVault',

          importance: Importance.high,

          priority: Priority.high,

        ),

        iOS: DarwinNotificationDetails(),

      ),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

    );

  }



  Future<void> cancelNoteReminder(String noteId) async {

    if (!_initialized) return;

    await _plugin.cancel(noteId.hashCode);

  }

}


