import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kidnav/geofence_page/geofence_map_viewpage.dart';

class GeofenceListPage extends StatefulWidget {
  const GeofenceListPage({Key? key}) : super(key: key);

  @override
  State<GeofenceListPage> createState() => _GeofenceListPageState();
}

class _GeofenceListPageState extends State<GeofenceListPage> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> _deleteGeofence(String name) async {
    CollectionReference geofencesCollection =
        usersCollection.doc(activeUser.email).collection('Geofences');
    await geofencesCollection.doc(name).delete();
  }

  void _viewGeofenceOnMap(List<LatLng> points) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeofenceMapViewPage(points: points),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference geofencesCollection =
        usersCollection.doc(activeUser.email).collection('Geofences');

    return Scaffold(
      appBar: AppBar(
        title: Text('Geofence List'),
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

              return ListTile(
                title: Text(
                  geofenceName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: points.map<Widget>((point) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 10),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lat: ${point.latitude}, Lng: ${point.longitude}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteGeofence(geofenceName);
                        setState(() {
                          geofenceDocs.removeAt(index);
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.map,
                        color: const Color(0xff3c2c74),
                      ),
                      onPressed: () {
                        _viewGeofenceOnMap(points);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
