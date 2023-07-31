import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import '../page/notification_screen.dart';

// Phải top level function (không trong class)
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessage = FirebaseMessaging.instance;

  final androidChannel = const AndroidNotificationChannel(
    'noti_android_channel',
    'noti_android_channel_name',
    description: 'abc',
  );

  final localNotification = FlutterLocalNotificationsPlugin();

  void handleMessageInApp(RemoteMessage? message) {
    if (message == null) {
      return;
    } else {
      navigatorKey.currentState?.pushNamed(
        NotificationScreen.route,
        arguments: message,
      );
    }
  }

  Future initLocalNotification() async {
    const ios = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: ios);

    await localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final message = RemoteMessage.fromMap(
          jsonDecode(notificationResponse.payload ?? ''),
        );
        handleMessageInApp(message);
      },
    );

    final platform = localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((message) => handleMessageInApp(message));
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageInApp);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) {
        final notification = message.notification;
        if (notification == null) return;
        localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      },
    );
  }

  Future<void> initNotification() async {
    await _firebaseMessage.requestPermission();
    final fcmToken = await _firebaseMessage.getToken();
    print('Token $fcmToken');
    initPushNotifications();
    initLocalNotification();
  }
}
