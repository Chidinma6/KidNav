import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kidnav/notification/notification_utilities.dart';
import 'package:kidnav/sms/twilio_service.dart';

class MainStatus extends StatefulWidget {
  const MainStatus({super.key});

  @override
  State<MainStatus> createState() => _MainStatusState();
}

class _MainStatusState extends State<MainStatus> {
  User? activeUser;
  CollectionReference<Map<String, dynamic>>? usersCollection;
  bool isCollectionInitialized = false;
  StreamSubscription<DocumentSnapshot>? locationSubscription;
  final TwilioService _twilioService = TwilioService();

  String resultMessage = '';
  String childFirstName = '';
  String parentPhoneNo = '';
  bool isInsideAnyGeofence = false;
  DateTime? resultMessageTime;

  @override
  void initState() {
    super.initState();
    initializeCurrentUser();
  }

  void initializeCurrentUser() async {
    activeUser = FirebaseAuth.instance.currentUser;
    if (activeUser != null) {
      await initializeCollection();
      await fetchChildFirstName();
      await fetchParentPhoneNo();
      startLocationSubscription();
    }
    setState(() {});
  }

  Future<void> initializeCollection() async {
    usersCollection = FirebaseFirestore.instance.collection("Users");
    isCollectionInitialized = true;
  }

  Future<void> fetchChildFirstName() async {
    if (activeUser != null && isCollectionInitialized) {
      try {
        final documentSnapshot =
            await usersCollection!.doc(activeUser!.email!).get();
        if (documentSnapshot.exists) {
          setState(() {
            childFirstName =
                documentSnapshot.data()?['Child\'s First Name'] ?? 'Child';
          });
        }
      } catch (error) {
        print("Error fetching child's first name: $error");
      }
    }
  }

  Future<void> fetchParentPhoneNo() async {
    if (activeUser != null && isCollectionInitialized) {
      try {
        final documentSnapshot =
            await usersCollection!.doc(activeUser!.email!).get();
        if (documentSnapshot.exists) {
          setState(() {
            parentPhoneNo =
                documentSnapshot.data()?['Parent\'s Phone Number'] ?? '';
          });
        }
      } catch (error) {
        print("Error fetching parent's phone number: $error");
      }
    }
  }

  void startLocationSubscription() {
    if (activeUser != null && isCollectionInitialized) {
      locationSubscription = usersCollection!
          .doc(activeUser!.email!)
          .collection('location_data')
          .doc("data")
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          var locationData = snapshot.data() as Map<String, dynamic>;
          double latitude = (locationData['Latitude'] as num).toDouble();
          double longitude = (locationData['Longitude'] as num).toDouble();
          checkPoint(latitude, longitude);
        }
      });
    }
  }

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

  double isLeft(
      double x1, double y1, double x2, double y2, double x, double y) {
    return (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1);
  }

  void checkPoint(double latitude, double longitude) {
    List<double> point = [latitude, longitude];

    if (activeUser != null && isCollectionInitialized) {
      usersCollection!
          .doc(activeUser!.email!)
          .collection('Geofences')
          .get()
          .then((querySnapshot) {
        bool foundInsideGeofence = false;
        String? currentGeofenceName;

        for (var doc in querySnapshot.docs) {
          final geofenceData = doc.data() as Map<String, dynamic>;
          final geofenceName = geofenceData['Geofence name'];
          final points = (geofenceData['points'] as List<dynamic>)
              .map((point) => [
                    (point['latitude'] as num).toDouble(),
                    (point['longitude'] as num).toDouble()
                  ])
              .toList();

          List<List<double>> polygon =
              points.map((e) => e.cast<double>()).toList();

          int result = windingNumber(point, polygon);

          if (result != 0) {
            foundInsideGeofence = true;
            currentGeofenceName = geofenceName;
            break;
          }
        }

        if (foundInsideGeofence && !isInsideAnyGeofence) {
          setState(() {
            resultMessage =
                '$childFirstName has entered geofence: $currentGeofenceName';
            resultMessageTime = DateTime.now();
          });
          sendNotification(resultMessage, activeUser!.email!);
          _twilioService.sendSms(parentPhoneNo,
              resultMessage); // Send SMS when child enters geofence
        } else if (!foundInsideGeofence && isInsideAnyGeofence) {
          setState(() {
            resultMessage = '$childFirstName has left the geofence: ';
            resultMessageTime = DateTime.now();
          });
          sendNotification(resultMessage, activeUser!.email!);
          _twilioService.sendSms(parentPhoneNo,
              resultMessage); // Send SMS when child leaves geofence
        }

        isInsideAnyGeofence = foundInsideGeofence;
      }).catchError((error) {
        print("Error checking geofence: $error");
      });
    }
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (activeUser == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 600),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xff3c2c74),
                Color.fromARGB(255, 66, 45, 138),
                Color.fromARGB(255, 11, 28, 102),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                resultMessageTime != null
                    ? '$resultMessage at ${DateFormat('yyyy-MM-dd HH:mm:ss').format(resultMessageTime!)}'
                    : resultMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
