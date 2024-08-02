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

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> _getLocation() async {
    try {
      final LocationData locationResult = await location.getLocation();
      final placemarks = await geocoding.placemarkFromCoordinates(
        locationResult.latitude!,
        locationResult.longitude!,
      );
      final address = placemarks.first;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(activeUser.email)
          .set({
        'latitude': locationResult.latitude,
        'longitude': locationResult.longitude,
        'address': '${address.street}, ${address.locality}, ${address.country}',
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true));
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
      final placemarks = await geocoding.placemarkFromCoordinates(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
      final address = placemarks.first;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(activeUser.email)
          .set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'address': '${address.street}, ${address.locality}, ${address.country}',
        'time located': Timestamp.now(),
      }, SetOptions(merge: true));
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
      print("done");
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          CustomTextButton(
            text: "Enable Live Location",
            onPressed: _listenLocation,
          ),
          const SizedBox(
            height: 25,
          ),
          CustomTextButton(
            text: "Stop Live Location",
            onPressed: _stopListening,
          ),
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
                          "Time: ${data['time located']?.toDate.toString() ?? ''}",
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
