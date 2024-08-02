import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class TestMap extends StatefulWidget {
  const TestMap({super.key});

  @override
  State<TestMap> createState() => _TestMapState();
}

class _TestMapState extends State<TestMap> {
  late GoogleMapController mapController;
  final locationController = Location();
  static const disneyWorld = LatLng(28.422027574112267, -81.58230514708008);
  LatLng? currentPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> fetchLocationUpdate() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
      serviceEnabled = await locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await locationController.requestService();
        if (!serviceEnabled) {
          print('Location service is disabled.');
          return;
        }
      }

      permissionGranted = await locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('Location permission denied.');
          return;
        }
      }

      var locationData = await locationController.getLocation();
      print('Location Data: $locationData');
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          currentPosition =
              LatLng(locationData.latitude!, locationData.longitude!);
        });
      }

      locationController.onLocationChanged.listen((currentLocation) {
        print('Current Location: $currentLocation');
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            currentPosition =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
          mapController.animateCamera(CameraUpdate.newLatLng(currentPosition!));
          print(currentPosition!);
        }
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  static const Marker waltdisneyMarker = Marker(
    markerId: MarkerId("waltdisneyMarker"),
    infoWindow: InfoWindow(title: "Walt Disney World"),
    icon: BitmapDescriptor.defaultMarker,
    position: disneyWorld,
  );

  static const Marker randomplace = Marker(
    markerId: MarkerId("random"),
    infoWindow: InfoWindow(title: "A random place"),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(28.419756885254998, -81.5824753645838),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchLocationUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: const MarkerId("current_location"),
                  infoWindow: const InfoWindow(title: "Current Location"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueMagenta),
                  position: currentPosition!,
                ),
                waltdisneyMarker,
                randomplace
              },
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: disneyWorld,
                zoom: 15.0,
              ),
            ),
    );
  }
}
