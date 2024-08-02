import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class TryAgain extends StatefulWidget {
  const TryAgain({Key? key}) : super(key: key);

  @override
  State<TryAgain> createState() => _TryAgainState();
}

class _TryAgainState extends State<TryAgain> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  final String googleApiKey =
      "AIzaSyB6AfQUuV4fZhJKPVCx3gejHXztQfu2y5I"; // Replace with your Google API key

  static const LatLng sourceLocation = LatLng(37.4221, -122.0853);

  static const LatLng destinationLocation = LatLng(37.4116, -122.0713);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  Set<Marker> markers = Set(); // Set for markers

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.getLocation().then(
      (location) {
        setState(() {
          currentLocation = location;
          updateMarkers(); // Update markers when current location is available
        });
      },
    );

    GoogleMapController googleMapController = await mapController.future;

    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
        updateMarkers(); // Update markers when location changes

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(newLocation.latitude!, newLocation.longitude!),
            ),
          ),
        );

        // Call the method to update polyline points
        updatePolyPoints();
      });
    });
  }

  void updateMarkers() {
    markers.clear(); // Clear existing markers
    if (currentLocation != null) {
      markers.add(Marker(
        markerId: MarkerId("currentLocation"),
        infoWindow: InfoWindow(title: "Current Location"),
        position:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      ));
    }

    markers.add(Marker(
      markerId: MarkerId("source"),
      infoWindow: InfoWindow(title: "Source Location"),
      position: sourceLocation,
    ));

    markers.add(Marker(
      markerId: MarkerId("destination"),
      infoWindow: InfoWindow(title: "Destination Location"),
      position: destinationLocation,
    ));
  }

  void updatePolyPoints() async {
    if (currentLocation == null) return;

    try {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude),
      );

      if (result.points.isNotEmpty) {
        setState(() {
          polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          // Adding source location to the beginning of the list
          polylineCoordinates.insert(0, sourceLocation);
        });
      } else {
        print("Error: ${result.errorMessage}");
      }
    } catch (e) {
      print("Exception caught: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 13.5,
              ),
              mapType: MapType.normal,
              markers: markers, // Use the markers set
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.indigo,
                  width: 6,
                ),
              },
            ),
    );
  }
}
