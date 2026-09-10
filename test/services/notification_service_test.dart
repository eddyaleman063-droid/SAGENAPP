import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  tz_data.initializeTimeZones();

  late _MockPlugin plugin;
  late NotificationService service;

  setUpAll(() {
    registerFallbackValue(0);
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
    registerFallbackValue(DateTimeComponents.time);
  });

  setUp(() {
    plugin = _MockPlugin();
    service = NotificationService.test(plugin);
  });

  group('NotificationService', () {
    test('is a singleton', () {
      final a = NotificationService.instance;
      final b = NotificationService.instance;
      expect(a, same(b));
    });

    test('test() constructor works without an injected plugin', () {
      expect(NotificationService.test(), isNotNull);
    });

    group('init', () {
      test('initializes the plugin and flags the service as ready', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        await service.init();
        await service.init();
        verify(() => plugin.initialize(any())).called(1);
      });

      test('resolves the local timezone when the platform responds', () async {
        const channel = MethodChannel('flutter_timezone');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              return {'identifier': 'America/New_York'};
            });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        await service.init();
        verify(() => plugin.initialize(any())).called(1);
      });

      test('stays uninitialized when the plugin throws', () async {
        when(() => plugin.initialize(any())).thenThrow(Exception('denied'));
        await service.init();
        await service.cancelAll();
      });
    });

    group('scheduleChestReminder', () {
      test('does not touch the plugin when uninitialized', () async {
        await service.scheduleChestReminder();
        verifyNever(
          () => plugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        );
      });

      test('schedules at 20:00 same day when now is before 20:00', () async {
        tz.setLocalLocation(tz.UTC);
        service.nowOverride = () => tz.TZDateTime(tz.local, 2026, 1, 1, 9, 0);
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancel(any())).thenAnswer((_) async {});
        when(
          () => plugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenAnswer((_) async {});
        await service.init();
        await service.scheduleChestReminder();
        verify(() => plugin.cancel(2000)).called(1);
        final captured = verify(
              () => plugin.zonedSchedule(
                any(),
                any(),
                any(),
                captureAny(),
                any(),
                androidScheduleMode: any(named: 'androidScheduleMode'),
                uiLocalNotificationDateInterpretation: any(
                  named: 'uiLocalNotificationDateInterpretation',
                ),
                matchDateTimeComponents: DateTimeComponents.time,
              ),
            ).captured,
            scheduled = captured.single as tz.TZDateTime;
        expect(scheduled.year, 2026);
        expect(scheduled.month, 1);
        expect(scheduled.day, 1);
        expect(scheduled.hour, 20);
      });

      test('schedules for the next day when now is past 20:00', () async {
        tz.setLocalLocation(tz.UTC);
        service.nowOverride = () => tz.TZDateTime(tz.local, 2026, 1, 1, 22, 0);
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancel(any())).thenAnswer((_) async {});
        when(
          () => plugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenAnswer((_) async {});
        await service.init();
        await service.scheduleChestReminder();
        final captured = verify(
              () => plugin.zonedSchedule(
                any(),
                any(),
                any(),
                captureAny(),
                any(),
                androidScheduleMode: any(named: 'androidScheduleMode'),
                uiLocalNotificationDateInterpretation: any(
                  named: 'uiLocalNotificationDateInterpretation',
                ),
                matchDateTimeComponents: DateTimeComponents.time,
              ),
            ).captured,
            scheduled = captured.single as tz.TZDateTime;
        expect(scheduled.year, 2026);
        expect(scheduled.month, 1);
        expect(scheduled.day, 2);
        expect(scheduled.hour, 20);
      });

      test('logs and swallows plugin errors', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancel(any())).thenAnswer((_) async {});
        when(
          () => plugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenThrow(Exception('boom'));
        await service.init();
        await service.scheduleChestReminder();
      });
    });

    group('scheduleStreakReminder', () {
      Future<void> initService() async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancel(any())).thenAnswer((_) async {});
        when(
          () => plugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenAnswer((_) async {});
        await service.init();
      }

      test('does not touch the plugin when uninitialized', () async {
        await service.scheduleStreakReminder(3);
        verifyNever(
          () => plugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        );
      });

      test('schedules with the active-streak message', () async {
        await initService();
        await service.scheduleStreakReminder(7);
        verify(
          () => plugin.zonedSchedule(
            2001,
            'Your fire is fading',
            any(that: contains('7-day')),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).called(1);
      });

      test(
        'schedules with the fresh-start message when streak is zero',
        () async {
          await initService();
          await service.scheduleStreakReminder(0);
          verify(
            () => plugin.zonedSchedule(
              2001,
              'The Arena awaits',
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
              matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
            ),
          ).called(1);
        },
      );

      test('logs and swallows plugin errors', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancel(any())).thenAnswer((_) async {});
        when(
          () => plugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenThrow(Exception('boom'));
        await service.init();
        await service.scheduleStreakReminder(2);
      });
    });

    group('cancelStreakReminder', () {
      test('does not touch the plugin when uninitialized', () async {
        await service.cancelStreakReminder();
        verifyNever(() => plugin.cancel(any()));
      });

      test('cancels the streak reminder', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancel(any())).thenAnswer((_) async {});
        await service.init();
        await service.cancelStreakReminder();
        verify(() => plugin.cancel(2001)).called(1);
      });

      test('logs plugin errors', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancel(any())).thenThrow(Exception('boom'));
        await service.init();
        await service.cancelStreakReminder();
      });
    });

    group('cancelAll', () {
      test('does not touch the plugin when uninitialized', () async {
        await service.cancelAll();
        verifyNever(() => plugin.cancelAll());
      });

      test('cancels all notifications', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancelAll()).thenAnswer((_) async {});
        await service.init();
        await service.cancelAll();
        verify(() => plugin.cancelAll()).called(1);
      });

      test('logs plugin errors', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(() => plugin.cancelAll()).thenThrow(Exception('boom'));
        await service.init();
        await service.cancelAll();
      });
    });

    group('showFreezeConsumedNotification', () {
      test('does not touch the plugin when uninitialized', () async {
        await service.showFreezeConsumedNotification(2);
        verifyNever(() => plugin.show(any(), any(), any(), any()));
      });

      test('shows the shield-consumed notification', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => plugin.show(any(), any(), any(), any()),
        ).thenAnswer((_) async {});
        await service.init();
        await service.showFreezeConsumedNotification(2);
        verify(
          () => plugin.show(
            2003,
            'Streak shield used',
            any(that: contains('2 shield')),
            any(),
          ),
        ).called(1);
      });

      test('logs plugin errors', () async {
        when(() => plugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => plugin.show(any(), any(), any(), any()),
        ).thenThrow(Exception('boom'));
        await service.init();
        await service.showFreezeConsumedNotification(2);
      });
    });
  });
}
