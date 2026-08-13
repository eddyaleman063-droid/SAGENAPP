import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@JsonEnum()
enum NotificationType { streak, analysis, tip, achievement, system }

@unfreezed
class NotificationItem with _$NotificationItem {
  NotificationItem._();

  factory NotificationItem({
    @Default('') String id,
    required String title,
    required String description,
    required NotificationType type,
    required DateTime date,
    @Default(false) bool isRead,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}
