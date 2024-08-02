// import 'dart:async'; // Import the async library for Timer
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// void main() {
//   // Schedule periodic notifications every 2 minutes
//   Timer.periodic(Duration(minutes: 2), (Timer t) {
//     sendNotification('Your message here', 'user@example.com');
//   });
// }

void sendNotification(String message, String userEmail) {
  // Create notification using Awesome Notifications
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(), // Unique ID for each notification
      channelKey: 'basic_channel',
      title: 'Geofence Alert',
      body: message,
      notificationLayout: NotificationLayout.Default,
    ),
  );

  // Store notification in Firestore
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  usersCollection
      .doc(userEmail)
      .collection('Geofence Alert History')
      .doc(timestamp)
      .set({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      })
      .then((value) => print('Notification stored in Firestore'))
      .catchError((error) => print('Failed to store notification: $error'));
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}
