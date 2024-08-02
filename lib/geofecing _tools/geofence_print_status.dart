import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:kidnav/notification/notification_utilities.dart';

class GeofencePrintStatus extends StatefulWidget {
  const GeofencePrintStatus({Key? key}) : super(key: key);

  @override
  State<GeofencePrintStatus> createState() => _GeofencePrintStatusState();
}

class _GeofencePrintStatusState extends State<GeofencePrintStatus> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  // Controllers for user input
  final latController = TextEditingController();
  final longController = TextEditingController();
  String resultMessage = '';
  String childFirstName = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchChildFirstName();
    // Initialize the timer to call checkPoint every 2 minutes
    _timer = Timer.periodic(Duration(minutes: 2), (timer) {
      checkPoint();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Fetch child's first name from Firestore
  void fetchChildFirstName() {
    usersCollection.doc(activeUser.email).get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          childFirstName =
              documentSnapshot.data()?['child\'s first name'] ?? 'Child';
        });
      }
    }).catchError((error) {
      print("Error fetching child's first name: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geofence Print Status'),
        backgroundColor: Color(0xffdcdae7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Input fields for latitude and longitude
            TextField(
              controller: latController,
              decoration: InputDecoration(
                labelText: 'Enter Latitude',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: longController,
              decoration: InputDecoration(
                labelText: 'Enter Longitude',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkPoint,
              child: Text('Check Point'),
            ),
            SizedBox(height: 10),
            Text(resultMessage),
          ],
        ),
      ),
    );
  }

  // Method to calculate the winding number
  int windingNumber(List<double> point, List<List<double>> polygon) {
    double x = point[0];
    double y = point[1];
    int num = polygon.length;
    int windingNumber = 0;

    for (int i = 0; i < num; i++) {
      double x1 = polygon[i][0];
      double y1 = polygon[i][1];
      double x2 = polygon[(i + 1) % num][0];
      double y2 = polygon[(i + 1) % num][1];

      if (y1 <= y) {
        if (y2 > y && isLeft(x1, y1, x2, y2, x, y) > 0) {
          windingNumber++;
        }
      } else {
        if (y2 <= y && isLeft(x1, y1, x2, y2, x, y) < 0) {
          windingNumber--;
        }
      }
    }

    return windingNumber;
  }

  // Helper method to check the relative position of the point
  double isLeft(
      double x1, double y1, double x2, double y2, double x, double y) {
    return (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
  }

  // Method to check if the point is inside any geofence
  void checkPoint() {
    double? latitude = double.tryParse(latController.text);
    double? longitude = double.tryParse(longController.text);

    if (latitude == null || longitude == null) {
      setState(() {
        resultMessage = 'Invalid coordinates';
      });
      return;
    }

    List<double> point = [latitude, longitude];
    bool isInsideAnyGeofence = false;

    usersCollection
        .doc(activeUser.email)
        .collection('Geofences')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final geofenceData = doc.data() as Map<String, dynamic>;
        final geofenceName = geofenceData['Geofence name'];
        final points = (geofenceData['points'] as List<dynamic>)
            .map((point) => [
                  (point['latitude'] as num).toDouble(),
                  (point['longitude'] as num).toDouble()
                ])
            .toList();

        // Ensure the points list is typed correctly as List<List<double>>
        List<List<double>> polygon =
            points.map((e) => e.cast<double>()).toList();

        int result = windingNumber(point, polygon);

        if (result != 0) {
          isInsideAnyGeofence = true;
          setState(() {
            resultMessage = '$childFirstName is in geofence: $geofenceName';
          });
          sendNotification('$childFirstName is in geofence: $geofenceName');
          break;
        }
      }

      if (!isInsideAnyGeofence) {
        setState(() {
          resultMessage = '$childFirstName is not in any geofence';
        });
        sendNotification('$childFirstName is not in any geofence');
      }
    });
  }

  // Method to send notification
  void sendNotification(String message) {
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
    usersCollection
        .doc(activeUser.email)
        .collection('Geofence Alert History')
        .doc(timestamp)
        .set({
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then((value) => print('Notification stored in Firestore'))
        .catchError((error) => print('Failed to store notification: $error'));
  }
}
