// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LatLng1 {
  double latitude;
  double longitude;

  LatLng1(this.latitude, this.longitude);
  @override
  String toString() {
    // TODO: implement toString
    return '$longitude,$latitude';
  }
}

class LatLngBounds1 {
  LatLng1 northeast;
  LatLng1 southwest;

  LatLngBounds1({required this.northeast, required this.southwest});

  bool contains(LatLng1 point) {
    return point.latitude >= southwest.latitude &&
        point.latitude <= northeast.latitude &&
        point.longitude >= southwest.longitude &&
        point.longitude <= northeast.longitude;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$southwest,$northeast';
  }
}

class GasStation {
  String name;
  String address;
  LatLng1 location;
  String placeID;
  GasStation(
      {required this.name,
      required this.address,
      required this.location,
      required this.placeID});
  @override
  String toString() {
    // TODO: implement toString
    return 'gas station: $name,$address,$location,$placeID\n';
  }
}

class RouteSegment {
  static int segmentSize = 3000;
  LatLng1? startPoint;
  late LatLng1 endPoint;
  List<LatLng1> points = [];
  late LatLngBounds1 bounds;
  bool refueled = false;
  RouteSegment({
    required this.startPoint,
  }) {
    endPoint = startPoint!;
    bounds = LatLngBounds1(
        northeast: LatLng1(startPoint!.latitude, startPoint!.longitude),
        southwest: LatLng1(startPoint!.latitude, startPoint!.longitude));
    // points.add(startPoint);
    startPoint = null;
  }
  bool extend(LatLng1 point) {
    LatLngBounds1 temp = LatLngBounds1(
        northeast:
            LatLng1(bounds.northeast.latitude, bounds.northeast.longitude),
        southwest:
            LatLng1(bounds.southwest.latitude, bounds.southwest.longitude));

    if (point.latitude >= bounds.northeast.latitude) {
      temp.northeast.latitude = point.latitude + 0.004;
    }
    if (point.longitude >= bounds.northeast.longitude) {
      temp.northeast.longitude = point.longitude + 0.004;
    }
    if (point.latitude <= bounds.southwest.latitude) {
      temp.southwest.latitude = point.latitude - 0.004;
    }
    if (point.longitude <= bounds.southwest.longitude) {
      temp.southwest.longitude = point.longitude - 0.004;
    }
    // print('temp: $temp');

    LatLng1 lat = LatLng1(temp.southwest.latitude, temp.northeast.longitude);
    LatLng1 lng = LatLng1(temp.northeast.latitude, temp.southwest.longitude);

    // print('latitudinal distance: ${calculateDistance(temp.northeast, lat)}');
    // print('longitudinal distance: ${calculateDistance(temp.northeast, lng)}');

    if ((calculateDistance(temp.northeast, lat) < segmentSize) &&
        (calculateDistance(temp.northeast, lng) < segmentSize)) {
      bounds = temp;
      endPoint = point;
      points.add(point);
      startPoint ??= point;
      return true;
    } else {
      return false;
    }
  }

  bool contains(LatLng1 point) {
    return point.latitude >= bounds.southwest.latitude &&
        point.latitude <= bounds.northeast.latitude &&
        point.longitude >= bounds.southwest.longitude &&
        point.longitude <= bounds.northeast.longitude;
  }

  static LatLng1 getSeed(LatLngBounds1 temp, LatLng1 point) {
    LatLng1 lat = LatLng1(temp.southwest.latitude, temp.northeast.longitude);
    LatLng1 lng = LatLng1(temp.northeast.latitude, temp.southwest.longitude);
    var latseed = LatLng1(0, 0);
    var lngseed = LatLng1(0, 0);
    if ((calculateDistance(temp.northeast, lat) < segmentSize)) {
      double newLat = (temp.northeast.latitude + temp.southwest.latitude) / 2;
      double newLng = (calculateDistance(temp.northeast, point) <
              calculateDistance(lng, point))
          ? temp.northeast.longitude
          : temp.southwest.longitude;
      latseed = LatLng1(newLat, newLng);
    }
    if (calculateDistance(temp.northeast, lng) < segmentSize) {
      double newLat = (calculateDistance(temp.northeast, point) <
              calculateDistance(lat, point))
          ? temp.northeast.latitude
          : temp.southwest.latitude;
      double newLng = (temp.northeast.longitude + temp.southwest.longitude) / 2;
      lngseed = LatLng1(newLat, newLng);
    } else {
      assert(false, 'New point is too far');
      return point;
    }
    return (calculateDistance(latseed, point) <
            calculateDistance(lngseed, point))
        ? latseed
        : lngseed;
  }

  static int calculateDistance(LatLng1 point1, LatLng1 point2) {
    double lat1 = point1.latitude;
    double lon1 = point1.longitude;
    double lat2 = point2.latitude;
    double lon2 = point2.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (6378137 * asin(sqrt(a))).round();
  }

  @override
  String toString() {
    return 'RouteSegment(bounds: $bounds, segmentSize: $segmentSize, refueled: $refueled,\n startPoint: $startPoint, endPoint: $endPoint, length:${points.length})\n';
  }
}

class MapServices {
  final String key = 'AIzaSyC7bvDC-YbKrrd1Xmwjjd_XIu0SPwkpYrU';
  // final String types = 'geocode';

  Future<List<GasStation>> getNearbyGasStation(
      LatLngBounds1 box, int segmentSize) async {
    // const String type = 'gas_station';
    const String rankby = 'prominence';
    const String language = 'en';
    const String opennow = 'true';
    const String keyword = 'petrol';
    final String location =
        '${(box.northeast.latitude + box.southwest.latitude) / 2},${(box.northeast.longitude + box.southwest.longitude) / 2}';
    final String radius = '${segmentSize * 0.75}';
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=$radius&key=$key&rankby=$rankby&language=$language&opennow=$opennow&keyword=$keyword';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    // print(response.body);
    List<GasStation> results = List.from(json['results'].map((element) {
      return GasStation(
          name: element['name'],
          address: element['vicinity'],
          location: LatLng1(element['geometry']['location']['lat'],
              element['geometry']['location']['lng']),
          placeID: 'place_id:${element['place_id']}');
    }));

    // print('gas stations: ${results['gas stations']}');
    return results;
  }

  Future<Map<String, dynamic>> getRoute(
    String origin,
    String destination,
  ) async {
    const String mode = 'driving';
    const String language = 'en';
    const String units = 'metric';
    const String departureTime = 'now';
    const String trafficModel = 'best_guess';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key&mode=$mode&language=$language&units=$units&departure_time=$departureTime&traffic_model=$trafficModel';
    print(Uri.parse(url));
    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);
    // print(json['geocoded_waypoints'].length);
    var results = {
      'bounds': LatLngBounds(
          northeast: LatLng(
            json['routes'][0]['bounds']['northeast']['lat'],
            json['routes'][0]['bounds']['northeast']['lng'],
          ),
          southwest: LatLng(
            json['routes'][0]['bounds']['southwest']['lat'],
            json['routes'][0]['bounds']['southwest']['lng'],
          )),
      'startLocation': LatLng(
        json['routes'][0]['legs'].first['start_location']['lat'],
        json['routes'][0]['legs'].first['start_location']['lng'],
      ),
      'endLocation': LatLng(
        json['routes'][0]['legs'].last['end_location']['lat'],
        json['routes'][0]['legs'].last['end_location']['lng'],
      ),
      'waypoints': json['routes'][0]['legs'].map((leg) {
        return LatLng(leg['end_location']['lat'], leg['end_location']['lng']);
      }).toList()
        ..insert(
            0,
            LatLng(
              json['routes'][0]['legs'].first['start_location']['lat'],
              json['routes'][0]['legs'].first['start_location']['lng'],
            )),
      'distance': json['routes'][0]['legs']
          .map((leg) => leg['distance']['value'])
          .reduce((value, element) => value + element),
      'duration': json['routes'][0]['legs']
          .map((leg) => leg['duration']['value'])
          .reduce((value, element) => value + element),
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polylineDecoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points'])
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList()
    };
    // print(response.body);
    return results;
  }

  Future<Map<String, dynamic>> getDirections(
      String origin, String destination, int currentRange, int maxRange) async {
    Map<String, dynamic> results = await getRoute(origin, destination);
    List<LatLng1> polylines = List.from(results['polylineDecoded'].map(
      (point) => LatLng1(point.latitude, point.longitude),
    ));

    if (results['distance'] as int > currentRange) {
      int segmentSize = (results['distance'] / 15) > 3000
          ? ((results['distance'] / 15) < maxRange * 0.7
              ? (results['distance'] / 15).round()
              : maxRange * 0.7)
          : 3000;
      RouteSegment.segmentSize = segmentSize;
      List<RouteSegment> boxes = [];
      RouteSegment currentBox = RouteSegment(startPoint: polylines.first);

      for (final LatLng1 point in polylines) {
        if (currentBox.extend(point)) {
          continue;
        } else {
          boxes.add(currentBox);
          currentBox = RouteSegment(
              startPoint: RouteSegment.getSeed(currentBox.bounds, point));
        }
      }
      boxes.add(currentBox);

      String waypoints = '&waypoints=optimize:true';
      for (RouteSegment box in boxes) {
        Map<String, dynamic> boxRoute = await getRoute(
            origin, '${box.endPoint.latitude},${box.endPoint.longitude}');
        int distCovered = boxRoute['distance'];
        if (distCovered < (currentRange - segmentSize)) {
          continue;
        } else {
          List<GasStation> gasStations =
              await getNearbyGasStation(box.bounds, segmentSize);
          // print(gasStations);
          if (gasStations.isNotEmpty) {
            waypoints += '|${gasStations.first.placeID}';
            currentRange = distCovered + maxRange;
            box.refueled = true;
          }
        }
      }

      // print('waypoints: $waypoints');
      results = await getRoute(origin, destination + waypoints);
    }
    return results;
  }
}
