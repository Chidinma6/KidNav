import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kidnav/location_permission/location_permission.dart';
import 'package:kidnav/map_page/main_map.dart';
import 'package:kidnav/status_page/status_display.dart';

class StatusOnly extends StatefulWidget {
  const StatusOnly({super.key});

  @override
  State<StatusOnly> createState() => _StatusOnlyState();
}

class _StatusOnlyState extends State<StatusOnly> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  @override
  void initState() {
    super.initState();
    requestLocationPermission(); // Use the function from the new file
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(activeUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                return ListView(
                  children: [
                    StatusDisplay(
                      text:
                          "Your Child,${data['child\'s first name'] ?? "No first name"}",
                      place: data['address'] ?? "No address available",
                      statuslat:
                          "Latitude: ${data['latitude']?.toString() ?? 'No data'}",
                      statuslng:
                          "Longitude: ${data['longitude']?.toString() ?? 'No data'}",
                      timeLocated:
                          "Time: ${data['time located']?.toDate().toString() ?? ''}",
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              MainMap(user_id: snapshot.data!.id),
                        ));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
