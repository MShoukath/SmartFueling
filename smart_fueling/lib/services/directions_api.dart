// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class MapServices {
  final String key = 'AIzaSyC7bvDC-YbKrrd1Xmwjjd_XIu0SPwkpYrU';
  // final String types = 'geocode';

  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    const String mode = 'driving';
    const String language = 'en';
    const String units = 'metric';
    const String departure_time = 'now';
    const String traffic_model = 'best_guess';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key&mode=$mode&language=$language&units=$units&departure_time=$departure_time&traffic_model=$traffic_model';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);
    print('origin: $origin , destination: $destination');
    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'bounds': LatLngBounds(
          northeast: LatLng(
            json['routes'][0]['bounds']['northeast']['lat'],
            json['routes'][0]['bounds']['northeast']['lng'],
          ),
          southwest: LatLng(
            json['routes'][0]['bounds']['southwest']['lat'],
            json['routes'][0]['bounds']['southwest']['lng'],
          )),
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'str_distance': json['routes'][0]['legs'][0]['distance']['text'],
      'distance': json['routes'][0]['legs'][0]['distance']['value'],
      'str_duration': json['routes'][0]['legs'][0]['duration']['text'],
      'duration': json['routes'][0]['legs'][0]['duration']['value'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points'])
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList()
    };
    print(results['polyline_decoded']);
    return results;
  }
}
