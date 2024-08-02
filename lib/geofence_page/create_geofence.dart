import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidnav/map_page/location_service.dart';

class CreateGeofence extends StatefulWidget {
  const CreateGeofence({super.key});

  @override
  State<CreateGeofence> createState() => _CreateGeofenceState();
}

class _CreateGeofenceState extends State<CreateGeofence> {
  final activeUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  final geofenceName = TextEditingController();
  final searchController = TextEditingController();

  late GoogleMapController mapController;

  List<LatLng> _points = [];
  List<Marker> _markers = [];
  List<Polygon> _polygons = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  static const covenant = LatLng(6.67347587321268, 3.160172297625705);

  Future<void> _savePointsToFirestore(String name) async {
    CollectionReference pointsCollection =
        usersCollection.doc(activeUser.email).collection('Geofences');

    List<Map<String, double>> points = _points.map((point) {
      return {
        'latitude': point.latitude,
        'longitude': point.longitude,
      };
    }).toList();

    await pointsCollection.doc(name).set({
      "Geofence name": name,
      'points': points,
    });
  }

  void _showNameInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Enter Geofence Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: geofenceName,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                geofenceName.clear();
              },
              child: Text('Clear'),
            ),
            TextButton(
              onPressed: () async {
                String name = geofenceName.text.trim();
                if (name.isNotEmpty) {
                  await _savePointsToFirestore(name);
                  geofenceName.clear();
                  setState(() {
                    _points.clear();
                    _markers.clear();
                    _polygons.clear();
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _onTap(LatLng position) {
    setState(() {
      // Check if the position already exists in the list
      final markerId = position.toString();
      final markerIndex =
          _markers.indexWhere((marker) => marker.markerId.value == markerId);

      if (markerIndex != -1) {
        // If marker exists, remove it
        _markers.removeAt(markerIndex);
        _points.removeAt(markerIndex);
      } else {
        // If marker does not exist, add it
        _markers.add(Marker(
          markerId: MarkerId(markerId),
          position: position,
          onTap: () => _onMarkerTap(markerId),
        ));
        _points.add(position);
      }

      // Update polygons
      _polygons = [
        Polygon(
          polygonId: PolygonId('polygon'),
          points: _points,
          strokeColor: Colors.blue,
          strokeWidth: 5,
          fillColor: Colors.blue.withOpacity(0.3),
        ),
      ];

      // Print the list of points to the console
      print(_points);
    });
  }

  void _onMarkerTap(String markerId) {
    setState(() {
      final markerIndex =
          _markers.indexWhere((marker) => marker.markerId.value == markerId);

      if (markerIndex != -1) {
        // Remove marker and point
        _markers.removeAt(markerIndex);
        _points.removeAt(markerIndex);

        // Update polygons
        _polygons = [
          Polygon(
            polygonId: PolygonId('polygon'),
            points: _points,
            strokeColor: Colors.blue,
            strokeWidth: 5,
            fillColor: Colors.blue.withOpacity(0.3),
          ),
        ];

        // Print the list of points to the console
        print(_points);
      }
    });
  }

  Future<void> _gotoPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await mapController;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffdcdae7),
        title: Text('Create Geofences'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: covenant,
              zoom: 15,
            ),
            markers: Set<Marker>.of(_markers),
            polygons: Set<Polygon>.of(_polygons),
            onTap: _onTap,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) {
                      print(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    var place =
                        await LocationService().getPlace(searchController.text);
                    _gotoPlace(place);
                  },
                  child: Icon(Icons.search),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showNameInputDialog(context);
        },
        label: const Text('Add Geofence'),
        icon: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}
