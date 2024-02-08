import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Thêm kiểu ENUM để định nghĩa các loại thông báo
enum NotificationType { vocabulary, grammar }

class NotificationManager {
  static Future<void> init() async {
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );

    var initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({required String message}) async {
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
        0, 'Thông báo', message, platformChannelSpecifics);
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> scheduleNotification({
    required String message,
    required DateTime scheduledTime,
    required int id,
    required NotificationType type, // Thêm một tham số mới cho loại thông báo
  }) async {
    var platformChannelSpecifics = NotificationDetails(
      iOS: IOSNotificationDetails(),
    );

    String title;
    switch (type) {
      case NotificationType.vocabulary:
        title = 'Từ vựng';
        break;
      case NotificationType.grammar:
        title = 'Ngữ pháp';
        break;
      default:
        title = 'Thông báo';
    }

    await flutterLocalNotificationsPlugin.schedule(
      id,
      title, // Sử dụng biến title thay vì cứng "Thông báo"
      message,
      scheduledTime,
      platformChannelSpecifics,
    );
  }

  static Future<void> cancelPeriodicNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
