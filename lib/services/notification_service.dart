import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import '../models/duty_task_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'duty_reminders';
  static const String _channelName = 'Duty Reminders';
  static const String _channelDescription =
      'Reminders for assigned preschool duties';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      try {
        tz.setLocalLocation(
          tz.getLocation('Asia/Kuala_Lumpur'),
        );
      } catch (_) {
        try {
          tz.setLocalLocation(
            tz.getLocation('Asia/Singapore'),
          );
        } catch (_) {
          tz.setLocalLocation(tz.UTC);
        }
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings: initializationSettings,
      );

      _isInitialized = true;

      // Permission failure should not stop initialization.
      try {
        await requestPermission();
      } catch (e) {
        debugPrint('Notification permission error: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('Notification initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);

      // Do not rethrow because notifications are optional.
    }
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> scheduleDutyReminders(List<DutyTask> duties) async {
    await initialize();

    for (final duty in duties) {
      final notificationId = _notificationIdForDuty(duty.id);

      // Cancel the previous reminder before rescheduling it.
      await _notifications.cancel(id: notificationId);

      if (duty.isCompleted) continue;

      final dutyStart = _nextDutyStart(duty);

      // Some duties, such as assembly roles, may not have a time.
      if (dutyStart == null) continue;

      final reminderTime = dutyStart.subtract(const Duration(minutes: 30));

      if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) {
        continue;
      }

      await _notifications.zonedSchedule(
        id: notificationId,
        title: 'Upcoming duty reminder',
        body:
            '${duty.dutyType} at ${duty.location} starts in 30 minutes.',
        scheduledDate: reminderTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),

        // Inexact scheduling avoids requiring exact-alarm permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'duty:${duty.id}',
      );
    }
  }

  Future<void> showDutySummary(int dutyCount) async {
    await initialize();

    await _notifications.show(
      id: 90001,
      title: 'My Duties',
      body: dutyCount == 0
          ? 'No duties are assigned to you today.'
          : 'You have $dutyCount duties assigned.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  int _notificationIdForDuty(int dutyId) {
    return 100000 + dutyId;
  }

  tz.TZDateTime? _nextDutyStart(DutyTask duty) {
    if (duty.time.trim().isEmpty) return null;

    final timeMatch = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(duty.time);

    if (timeMatch == null) return null;

    int hour = int.parse(timeMatch.group(1)!);
    final minute = int.parse(timeMatch.group(2)!);
    final period = timeMatch.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final weekday = _weekdayNumber(duty.day);
    if (weekday == null) return null;

    final now = tz.TZDateTime.now(tz.local);
    int daysAhead = weekday - now.weekday;

    if (daysAhead < 0) {
      daysAhead += 7;
    }

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysAhead,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }

  int? _weekdayNumber(String day) {
    switch (day.trim().toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return null;
    }
  }
}