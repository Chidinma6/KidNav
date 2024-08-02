import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kidnav/map_page/main_map.dart';
import 'package:kidnav/status_page/custom_text_button.dart';
import 'package:kidnav/status_page/status_display.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class SimulateStatusPage extends StatefulWidget {
  const SimulateStatusPage({Key? key}) : super(key: key);

  @override
  State<SimulateStatusPage> createState() => _SimulateStatusPageState();
}

class _SimulateStatusPageState extends State<SimulateStatusPage> {
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Timer? _simulationTimer;
  int _currentSimulationIndex = 0;

  final List<Map<String, double>> _simulationCoordinates = [
    {
      'latitude': 6.715219,
      'longitude': 3.340266
    }, // Faith Tabernacle, Canaanland
    {'latitude': 6.719070, 'longitude': 3.339989}, // Canaanland Gate 1
    {'latitude': 6.722591, 'longitude': 3.336804}, // Canaanland Gate 2
    {'latitude': 6.721768, 'longitude': 3.332958}, // Ota Idiroko Road
    {'latitude': 6.719485, 'longitude': 3.329923}, // Covenant University
    {
      'latitude': 6.719452,
      'longitude': 3.328396
    }, // Covenant University Main Gate
    {'latitude': 6.717408, 'longitude': 3.323899}, // Bell's University Entrance
    {
      'latitude': 6.715228,
      'longitude': 3.321859
    }, // Bells University Main Campus
  ];

  Future<void> _updateLocation(Map<String, double> coordinates) async {
    final placemarks = await geocoding.placemarkFromCoordinates(
      coordinates['latitude']!,
      coordinates['longitude']!,
    );
    final address = placemarks.first;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(activeUser.email)
        .set({
      'latitude': coordinates['latitude'],
      'longitude': coordinates['longitude'],
      'address': '${address.street}, ${address.locality}, ${address.country}',
      'time located': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    const double speedFactor =
        0.0005; // Adjust this factor to control the speed of movement

    _simulationTimer = Timer.periodic(Duration(milliseconds: 6000), (timer) {
      if (_currentSimulationIndex < _simulationCoordinates.length) {
        final coordinates = _simulationCoordinates[_currentSimulationIndex];
        _updateLocation(coordinates); // Update location in Firestore
        _currentSimulationIndex++;
      } else {
        _currentSimulationIndex = 0;
        _simulationTimer?.cancel(); // Stop simulation when finished
      }
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  Future<void> _getLocation() async {
    try {
      final LocationData locationResult = await location.getLocation();
      await _updateLocation({
        'latitude': locationResult.latitude!,
        'longitude': locationResult.longitude!,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _listenLocation() async {
    _getLocation();
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((LocationData currentLocation) async {
      await _updateLocation({
        'latitude': currentLocation.latitude!,
        'longitude': currentLocation.longitude!,
      });
    });
  }

  void _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  void _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print("Location permission granted");
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  void dispose() {
    _stopListening();
    _stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            CustomTextButton(
              text: "Enable Live Location",
              onPressed: _listenLocation,
            ),
            SizedBox(height: 25),
            CustomTextButton(
              text: "Stop Live Location",
              onPressed: _stopListening,
            ),
            SizedBox(height: 25),
            CustomTextButton(
              text: "Start Simulation",
              onPressed: _startSimulation,
            ),
            SizedBox(height: 25),
            CustomTextButton(
              text: "Stop Simulation",
              onPressed: _stopSimulation,
            ),
            SizedBox(height: 40),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(activeUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                return StatusDisplay(
                  text:
                      "Your Child, ${data['child\'s first name'] ?? "No first name"}",
                  place: data['address'] ?? "No address available",
                  statuslat:
                      "Latitude: ${data['latitude']?.toString() ?? 'No data'}",
                  statuslng:
                      "Longitude: ${data['longitude']?.toString() ?? 'No data'}",
                  timeLocated:
                      "Time: ${data['time located']?.toDate().toString() ?? ''}",
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MainMap(user_id: snapshot.data!.id),
                    ));
                  },
                );
              },
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
