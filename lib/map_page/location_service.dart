import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationService {
  final String key = "PUT GOOGLE MAP API KEY HERE";

  Future<String> getPlaceId(String input) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = convert.jsonDecode(response.body);

      if (json['candidates'] != null && json['candidates'].isNotEmpty) {
        var placeId = json['candidates'][0]['place_id'] as String;
        print(placeId);
        return placeId;
      } else {
        throw Exception('No candidates found for the provided input.');
      }
    } else {
      throw Exception('Failed to load place ID: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    try {
      final placeId = await getPlaceId(input);

      final String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key";

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var json = convert.jsonDecode(response.body);

        if (json['result'] != null) {
          var results = json['result'] as Map<String, dynamic>;
          print(results);
          return results;
        } else {
          throw Exception('No details found for the place ID.');
        }
      } else {
        throw Exception(
            'Failed to load place details: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key";

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    if (json['routes'] != null && json['routes'].isNotEmpty) {
      var results = {
        'bounds_ne': json['routes'][0]['bounds']['northeast'],
        'bounds_sw': json['routes'][0]['bounds']['southwest'],
        'start_location': json['routes'][0]['legs'][0]['start_location'],
        'end_location': json['routes'][0]['legs'][0]['end_location'],
        'polyline': json['routes'][0]['overview_polyline']['points'],
        'polyline_decoded': PolylinePoints()
            .decodePolyline(json['routes'][0]['overview_polyline']['points']),
      };
      return results;
    } else {
      throw Exception('No routes found.');
    }
  }
}
