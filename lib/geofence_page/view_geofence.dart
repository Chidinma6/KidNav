import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewGeofence extends StatefulWidget {
  const ViewGeofence({super.key});

  @override
  State<ViewGeofence> createState() => _ViewGeofenceState();
}

class _ViewGeofenceState extends State<ViewGeofence> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  late GoogleMapController mapController;
  List<Marker> _markers = [];
  List<Polygon> _polygons = [];

  @override
  void initState() {
    super.initState();
    // Load geofences when the state is initialized
    _loadGeofences();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Set initial camera position after the map is created
    _setInitialCameraPosition();
  }

  Future<void> _loadGeofences() async {
    CollectionReference geofencesCollection =
        usersCollection.doc(activeUser.email).collection('Geofences');

    // Get all geofence documents for the active user
    QuerySnapshot snapshot = await geofencesCollection.get();

    for (var doc in snapshot.docs) {
      List<LatLng> points = [];
      List<Map<String, dynamic>> pointsData =
          List<Map<String, dynamic>>.from(doc['points']);

      // Convert points data to LatLng objects
      for (var pointData in pointsData) {
        points.add(LatLng(pointData['latitude'], pointData['longitude']));
      }

      setState(() {
        // Add the polygon to the list
        _polygons.add(
          Polygon(
            polygonId: PolygonId(doc.id),
            points: points,
            strokeColor: Colors.blue,
            strokeWidth: 5,
            fillColor: Colors.blue.withOpacity(0.3),
          ),
        );

        // Calculate the centroid of the polygon
        LatLng centroid = _calculateCentroid(points);

        // Add a marker at the centroid with the geofence name
        _markers.add(
          Marker(
            markerId: MarkerId('centroid_${doc.id}'),
            position: centroid,
            infoWindow: InfoWindow(title: doc.id),
          ),
        );
      });
    }

    // Set the initial camera position after loading geofences
    _setInitialCameraPosition();
  }

  // Calculate the centroid of a polygon
  LatLng _calculateCentroid(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;

    // Sum up all latitudes and longitudes
    for (var point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    // Calculate the average to find the centroid
    int totalPoints = points.length;
    return LatLng(latitude / totalPoints, longitude / totalPoints);
  }

  // Set the initial camera position to the center of the bounding box of all polygons
  void _setInitialCameraPosition() {
    if (_polygons.isEmpty) return;

    // Initialize min and max values with the first point
    double minLat = _polygons.first.points.first.latitude;
    double maxLat = _polygons.first.points.first.latitude;
    double minLng = _polygons.first.points.first.longitude;
    double maxLng = _polygons.first.points.first.longitude;

    // Iterate through all points to find the bounding box
    for (var polygon in _polygons) {
      for (var point in polygon.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }

    // Calculate the center of the bounding box
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;
    LatLng center = LatLng(centerLat, centerLng);

    // Animate the camera to the calculated center position
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: center, zoom: 14),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Geofences'),
        backgroundColor: Color(0xffdcdae7),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Temporary target, will be updated
          zoom: 1, // Temporary zoom, will be updated
        ),
        markers: Set<Marker>.of(_markers),
        polygons: Set<Polygon>.of(_polygons),
      ),
    );
  }
}
