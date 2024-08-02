// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kidnav/map_page/location_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polyLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  static const LatLng _kGooglePlex =
      LatLng(37.42796133580664, -122.085749655962);

  static const LatLng _kLake = LatLng(37.43296265331129, -122.08832357078792);

  //////////// -----METHODS------ /////////////////
  Future<void> _gotoPlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    final GoogleMapController controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25));
    _setMarker(LatLng(lat, lng));
  }

  Future<void> _gotoChild() async {
    final GoogleMapController controller = await mapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _kLake, zoom: 12),
    ));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(markerId: MarkerId("marker"), position: point),
      );
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    setState(() {
      _polygons.add(Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polyLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ));
    });
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(polylineIdVal),
          width: 2,
          color: Colors.blue,
          points: points
              .map(
                (point) => LatLng(point.latitude, point.longitude),
              )
              .toList(),
        ),
      );
    });
  }

  //////////////// ------METHODS------/////////////////

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _setMarker(LatLng(37.42796133580664, -122.085749655962));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _originController,
                      decoration: const InputDecoration(hintText: "Origin"),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                    TextFormField(
                      controller: _destinationController,
                      decoration:
                          const InputDecoration(hintText: "Destination"),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  var directions = await LocationService().getDirections(
                    _originController.text,
                    _destinationController.text,
                  );
                  _gotoPlace(
                    directions['start_location']['lat'],
                    directions['start_location']['lng'],
                    directions['bounds_ne'],
                    directions['bounds_sw'],
                  );

                  _setPolyline(directions['polyline_decoded']);
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController.complete(controller);
              },
              initialCameraPosition:
                  CameraPosition(target: _kGooglePlex, zoom: 13.5),
              mapType: MapType.normal,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              onTap: (point) {
                setState(() {
                  polyLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gotoChild,
        label: const Text('To the Child'),
        icon: const Icon(Icons.directions),
      ),
    );
  }
}
