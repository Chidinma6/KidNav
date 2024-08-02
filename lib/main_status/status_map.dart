import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StatusMap extends StatefulWidget {
  const StatusMap({super.key});

  @override
  State<StatusMap> createState() => _StatusMapState();
}

class _StatusMapState extends State<StatusMap> {
  User? activeUser;
  late CollectionReference<Map<String, dynamic>> usersCollection;

  GoogleMapController? mapController;
  List<LatLng> polylineCoordinates = []; // Coordinates for the polyline path
  LatLng? previousLocation;
  LatLng? initialLocation; // Initial location for the starting marker

  @override
  void initState() {
    super.initState();
    activeUser = FirebaseAuth.instance.currentUser;
    if (activeUser != null) {
      usersCollection = FirebaseFirestore.instance.collection("Users");
      initialLocation = null; // Initially no initial marker
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _updateMarkerPosition(LatLng position) async {
    if (previousLocation == null) {
      setState(() {
        initialLocation = position; // Set initial location if it's null
      });
    }
    setState(() {
      polylineCoordinates.add(position); // Add position to polyline path
      previousLocation = position;
    });

    await mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: position,
        zoom: 25,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (activeUser == null) {
      return Center(child: Text("User not logged in"));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection
            .doc(activeUser!.email)
            .collection("location_data")
            .doc("data")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;

          if (data == null ||
              data['Latitude'] == null ||
              data['Longitude'] == null) {
            return Center(child: Text("Location data is not available"));
          }

          final double latitude = (data['Latitude'] as num).toDouble();
          final double longitude = (data['Longitude'] as num).toDouble();
          final LatLng currentLocation = LatLng(latitude, longitude);

          _updateMarkerPosition(currentLocation);

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 18,
            ),
            mapType: MapType.normal,
            markers: {
              if (initialLocation != null)
                Marker(
                  markerId: MarkerId("startMarker"),
                  position: initialLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor
                      .hueGreen), // Custom icon for starting marker
                ),
              Marker(
                markerId: MarkerId("endMarker"),
                position: currentLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueMagenta), // Marker for current location
              ),
            },
            polylines: {
              Polyline(
                polylineId: PolylineId("poly"),
                color: Colors.blue,
                width: 3,
                points: polylineCoordinates,
              ),
            },
          );
        },
      ),
    );
  }
}
