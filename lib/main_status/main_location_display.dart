import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:kidnav/status_page/status_display.dart';

class MainLocationDisplay extends StatefulWidget {
  @override
  State<MainLocationDisplay> createState() => _MainLocationDisplayState();
}

class _MainLocationDisplayState extends State<MainLocationDisplay> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  String childFirstName = '';

  @override
  void initState() {
    super.initState();
    fetchChildFirstName();
  }

  void fetchChildFirstName() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(activeUser.email)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          childFirstName =
              documentSnapshot.data()?['Child\'s First Name'] ?? 'Child';
        });
      }
    }).catchError((error) {
      print("Error fetching child's first name: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 216, 207, 220),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(activeUser.email)
                .collection("location_data")
                .doc("data")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 5),
                    Text(
                      "Connection with Tracker is Lost,\nPlease connect to Tracker",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                ));
              }
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  !snapshot.data!.exists) {
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              return FutureBuilder<List<geocoding.Placemark>>(
                future: geocoding.placemarkFromCoordinates(
                  data['Latitude'],
                  data['Longitude'],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No address available',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final placemark = snapshot.data!.first;
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: StatusDisplay(
                      text: "Your Child, $childFirstName, is located at:",
                      place:
                          "Address: ${placemark.name}, ${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}",
                      statuslat:
                          "Latitude: ${data['Latitude']?.toString() ?? 'No data'}",
                      statuslng:
                          "Longitude: ${data['Longitude']?.toString() ?? 'No data'}",
                      timeLocated: "Time: ${data['date_time'] ?? ''}",
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
