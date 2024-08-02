import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotifTest extends StatefulWidget {
  const NotifTest({super.key});

  @override
  State<NotifTest> createState() => _NotifTestState();
}

class _NotifTestState extends State<NotifTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 1,
              channelKey: "basic_channel",
              title: "Hello world",
              body: "Yay! I have local notifications working now!",
              notificationLayout: NotificationLayout.Default,
              displayOnForeground: true,
              autoDismissible: false,
              category: NotificationCategory.Reminder,
            ),
          );
          Future.delayed(Duration(seconds: 5), () {
            AwesomeNotifications().dismiss(1);
          });
        },
        child: Icon(
          Icons.notification_add,
        ),
      ),
    );
  }
}
