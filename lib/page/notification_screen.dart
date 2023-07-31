import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const route = '/notification_screen';

  @override
  Widget build(BuildContext context) {
    final RemoteMessage message =
        ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Column(
        children: [
          const Center(
            child: Text('Notification Page'),
          ),
          Center(
            child: Text(message.notification?.title ?? ''),
          ),
          Center(
            child: Text(message.notification?.body ?? ''),
          ),
          Center(
            child: Text('${message.data}'),
          ),
        ],
      ),
    );
  }
}
