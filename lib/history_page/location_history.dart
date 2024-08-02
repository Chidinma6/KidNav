import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationHistory extends StatefulWidget {
  @override
  _LocationHistoryState createState() => _LocationHistoryState();
}

class _LocationHistoryState extends State<LocationHistory> {
  final User activeUser = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic>? latestLocationData;
  final Map<String, String> addressCache = {}; // Cache for addresses

  @override
  void initState() {
    super.initState();
    _listenToLocationData();
  }

  void _listenToLocationData() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(activeUser.email)
        .collection("location_data")
        .doc("data")
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data != latestLocationData) {
          setState(() {
            latestLocationData = data;
          });
          _saveLocationData(data);
        }
      }
    });
  }

  Future<void> _saveLocationData(Map<String, dynamic> data) async {
    final collectionRef = FirebaseFirestore.instance
        .collection("Users")
        .doc(activeUser.email)
        .collection("location_history");

    final querySnapshot = await collectionRef.get();
    final docCount = querySnapshot.size;

    final newDocId = docCount.toString();

    collectionRef
        .doc(newDocId)
        .set(data)
        .then((value) => print("Location Data Saved with ID $newDocId"))
        .catchError((error) => print("Failed to save location data: $error"));
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    String key = '$latitude,$longitude';
    if (addressCache.containsKey(key)) {
      return addressCache[key]!;
    } else {
      try {
        List<geocoding.Placemark> placemarks =
            await geocoding.placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          String address =
              '${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
          addressCache[key] = address;
          return address;
        } else {
          return 'Unknown address';
        }
      } catch (e) {
        return 'Error fetching address';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location History'),
        backgroundColor: Color(0xffdcdae7),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(activeUser.email)
            .collection("location_history")
            .orderBy('date_time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No saved location data available',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              double latitude = doc['Latitude'];
              double longitude = doc['Longitude'];
              String dateTime = doc['date_time'];

              return FutureBuilder<String>(
                future: _getAddress(latitude, longitude),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Fetching Address...'),
                      subtitle: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text('Error fetching address'),
                    );
                  }
                  return ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${snapshot.data}'),
                        Text('Latitude: $latitude'),
                        Text('Longitude: $longitude'),
                        Text('Date Time: $dateTime'),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
