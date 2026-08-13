import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../services/app_logger.dart';

/// Manages local and push notification scheduling.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._() : _logger = AppLogger();
  final AppLogger _logger;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'chest_reminder';
  static const String _channelName = 'Daily Reminder';
  static const String _channelDesc =
      'Reminder to open your daily chest in SAGEN';
  static const int _reminderId = 2000;

  static const String _retentionChannelId = 'streak_retention';
  static const String _retentionChannelName = 'Streak Retention';
  static const String _retentionChannelDesc =
      'Alerts to keep your streak active in SAGEN';
  static const int _streakReminderId = 2001;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        final name = tzInfo.identifier;
        tz.setLocalLocation(tz.getLocation(name));
        _logger.info('Local timezone set: $name');
      } catch (e) {
        _logger.warning(
          'Could not resolve local timezone, falling back to UTC: $e',
        );
      }
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin.initialize(settings);
      _initialized = true;
      _logger.info('NotificationService initialized');
    } catch (e) {
      _logger.error('NotificationService init failed', e);
    }
  }

  Future<void> scheduleChestReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_reminderId);
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        _reminderId,
        'Your daily chest awaits!',
        'Don\'t forget to claim your daily reward in SAGEN. Open the app and tap the chest.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      _logger.info('Daily chest reminder scheduled at 20:00');
    } catch (e) {
      _logger.error('scheduleChestReminder failed', e);
    }
  }

  Future<void> scheduleStreakReminder(int currentStreak) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_streakReminderId);
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        18,
      );

      String title;
      String body;
      if (currentStreak > 0) {
        title = 'Your fire is fading';
        body =
            'You\'re about to lose your $currentStreak-day streak. Enter now and defend your rank.';
      } else {
        title = 'The Arena awaits';
        body =
            'Your next cybersecurity lesson is ready. Do you accept the challenge?';
      }

      const androidDetails = AndroidNotificationDetails(
        _retentionChannelId,
        _retentionChannelName,
        channelDescription: _retentionChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.zonedSchedule(
        _streakReminderId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      _logger.info('Streak reminder scheduled for 24h from now');
    } catch (e) {
      _logger.error('scheduleStreakReminder failed', e);
    }
  }

  Future<void> cancelStreakReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_streakReminderId);
    } catch (e) {
      _logger.error('cancelStreakReminder failed', e);
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      _logger.error('cancelAll failed', e);
    }
  }

  Future<void> showFreezeConsumedNotification(int remainingFreezes) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        _retentionChannelId,
        _retentionChannelName,
        channelDescription: _retentionChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.show(
        _streakReminderId + 2,
        'Streak shield used',
        'A shield protected your streak. $remainingFreezes shield(s) remaining.',
        details,
      );
    } catch (e) {
      _logger.error('showFreezeConsumedNotification failed', e);
    }
  }
}
