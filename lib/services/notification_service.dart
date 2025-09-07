import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> scheduleWorkoutReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_reminders',
          'Workout Reminders',
          channelDescription: 'Reminders for workout sessions',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleMealReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Meal Reminders',
          channelDescription: 'Reminders for meal times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleProgressReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'progress_reminders',
          'Progress Reminders',
          channelDescription: 'Reminders for progress tracking',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  // Predefined reminder schedules
  static Future<void> setupDefaultReminders() async {
    final now = DateTime.now();
    
    // Workout reminders (every day at 7:00 AM and 7:00 PM)
    await scheduleWorkoutReminder(
      id: 1,
      title: 'Время тренировки! 💪',
      body: 'Не забудь про тренировку сегодня. Твой прогресс ждет!',
      scheduledTime: DateTime(now.year, now.month, now.day, 7, 0),
    );

    await scheduleWorkoutReminder(
      id: 2,
      title: 'Вечерняя тренировка 🌅',
      body: 'Отличное время для вечерней тренировки!',
      scheduledTime: DateTime(now.year, now.month, now.day, 19, 0),
    );

    // Meal reminders
    await scheduleMealReminder(
      id: 3,
      title: 'Время завтрака! 🍳',
      body: 'Не забудь позавтракать для энергии на весь день',
      scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
    );

    await scheduleMealReminder(
      id: 4,
      title: 'Время обеда! 🥗',
      body: 'Время для питательного обеда',
      scheduledTime: DateTime(now.year, now.month, now.day, 13, 0),
    );

    await scheduleMealReminder(
      id: 5,
      title: 'Время ужина! 🍽️',
      body: 'Легкий ужин для завершения дня',
      scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
    );

    // Progress reminder (weekly)
    await scheduleProgressReminder(
      id: 6,
      title: 'Время зафиксировать прогресс! 📊',
      body: 'Сделай фото для отслеживания изменений',
      scheduledTime: DateTime(now.year, now.month, now.day, 18, 0),
    );
  }

  // Legacy methods for compatibility
  Future<void> scheduleProteinReminder() async {
    await scheduleMealReminder(
      id: 100,
      title: 'Белок! 💪',
      body: 'Время для белкового перекуса',
      scheduledTime: DateTime.now().add(const Duration(hours: 3)),
    );
  }

  Future<void> scheduleSupplementsReminder() async {
    await scheduleMealReminder(
      id: 101,
      title: 'Витамины! 💊',
      body: 'Не забудь принять добавки',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
    );
  }
}