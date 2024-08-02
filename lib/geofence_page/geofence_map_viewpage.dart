import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeofenceMapViewPage extends StatelessWidget {
  final List<LatLng> points;

  const GeofenceMapViewPage({required this.points});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geofence Map View'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: points.isNotEmpty ? points.first : LatLng(0, 0),
          zoom: 15,
        ),
        polygons: {
          Polygon(
            polygonId: PolygonId('geofence_polygon'),
            points: points,
            strokeColor: Colors.blue,
            strokeWidth: 2,
            fillColor: Colors.blue.withOpacity(0.3),
          ),
        },
      ),
    );
  }
}
