// Print polygon variable with geofenceName again when tapped

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeofenceAnalyser extends StatefulWidget {
  const GeofenceAnalyser({Key? key}) : super(key: key);

  @override
  State<GeofenceAnalyser> createState() => _GeofenceAnalyserState();
}

class _GeofenceAnalyserState extends State<GeofenceAnalyser> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  @override
  Widget build(BuildContext context) {
    CollectionReference geofencesCollection =
        usersCollection.doc(activeUser.email).collection('Geofences');

    return Scaffold(
      appBar: AppBar(
        title: Text('Geofence Analyser'),
        backgroundColor: Color(0xffdcdae7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: geofencesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final geofenceDocs = snapshot.data?.docs ?? [];

          if (geofenceDocs.isEmpty) {
            return Center(
              child: Text(
                'No Saved Geofence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.separated(
            itemCount: geofenceDocs.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final geofenceData =
                  geofenceDocs[index].data() as Map<String, dynamic>;
              final geofenceName = geofenceData['Geofence name'];
              final points = geofenceData['points']
                  .map<LatLng>(
                      (point) => LatLng(point['latitude'], point['longitude']))
                  .toList();

              final polygon = points
                  .map((point) => [point.latitude, point.longitude])
                  .toList();

              // Print polygon variable with geofenceName
              print('final List<List<double>> $geofenceName = $polygon;');

              return ListTile(
                title: Text(
                  geofenceName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // Print polygon variable with geofenceName again when tapped
                  print('final List<List<double>> $geofenceName = $polygon;');
                },
              );
            },
          );
        },
      ),
    );
  }
}
