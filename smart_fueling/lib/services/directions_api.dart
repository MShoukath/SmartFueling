// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class LatLng {
//   double latitude;
//   double longitude;

//   LatLng(this.latitude, this.longitude);
//   @override
//   String toString() {
//     return '$longitude,$latitude';
//   }
// }

// class LatLngBounds {
//   LatLng northeast;
//   LatLng southwest;

//   LatLngBounds({required this.northeast, required this.southwest});

//   bool contains(LatLng point) {
//     return point.latitude >= southwest.latitude &&
//         point.latitude <= northeast.latitude &&
//         point.longitude >= southwest.longitude &&
//         point.longitude <= northeast.longitude;
//   }

//   @override
//   String toString() {
//     return '$southwest,$northeast';
//   }
// }

class LatLng1 {
  double latitude;
  double longitude;

  LatLng1(this.latitude, this.longitude);
  @override
  String toString() {
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
    return '$southwest,$northeast';
  }
}

class GasStation {
  String name;
  String address;
  LatLng1 location;
  String placeID;
  int fromDistance = 0;
  int toDistance = 0;
  int toDuration = 0;
  int fromDuration = 0;
  GasStation(
      {required this.name,
      required this.address,
      required this.location,
      required this.placeID});
  @override
  String toString() {
    return 'gas station: $name,toDistance:$toDistance, total distance: ${toDistance + fromDistance}, total duration: ${fromDuration + toDuration}\n';
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
    LatLng1? endPoint,
  }) {
    endPoint = endPoint ?? startPoint!;
    bounds = LatLngBounds1(
        northeast: LatLng1(startPoint!.latitude, startPoint!.longitude),
        southwest: LatLng1(startPoint!.latitude, startPoint!.longitude));
    points.add(startPoint!);
    startPoint = null;
  }
  bool extend(LatLng1 point, int segmentSize) {
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
      // assert(false, 'New point is too far');
      return point;
    }
    LatLng1 seed =
        (calculateDistance(latseed, point) < calculateDistance(lngseed, point))
            ? latseed
            : lngseed;

    return seed;
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
  final String key = 'AIzaSyBnH_1dS8lyzat1tGHbSpil3RnpvWMNiDM';
  // final String types = 'geocode';

  Future<Map<String, dynamic>> getNearbyGasStation(
      RouteSegment box, int segmentSize) async {
    // const String type = 'gas_station';
    const String rankby = 'distance';
    const String language = 'en';
    const String opennow = 'true';
    const String keyword = 'gas';
    final String location =
        '${box.points[box.points.length ~/ 7].latitude},${box.points[box.points.length ~/ 7].longitude}';
    // final String radius = '${segmentSize * 2}';
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&key=$key&rankby=$rankby&language=$language&opennow=$opennow&keyword=$keyword';
    var response = await http.get(Uri.parse(url));
    print('url: $url');
    var json = convert.jsonDecode(response.body);
    // print(response.body);
    json['results'] = json['results'].take(10).toList();
    String gasStationWaypoints = '';
    List<GasStation> gasStations = List.from(json['results'].map((element) {
      gasStationWaypoints += 'place_id:${element['place_id']}|';
      return GasStation(
          name: element['name'],
          address: element['vicinity'],
          location: LatLng1(element['geometry']['location']['lat'],
              element['geometry']['location']['lng']),
          placeID: 'place_id:${element['place_id']}');
    }));
    var results = {
      'gasStations': gasStations,
      'waypoints':
          gasStationWaypoints.substring(0, gasStationWaypoints.length - 1),
    };
    // print('gas stations: ${results['gas stations']}');
    return results;
  }

  Future<Map<String, dynamic>> getDistanceMatrix(
      String origins, String destinations) async {
    const String mode = 'driving';
    const String language = 'en';
    const String units = 'metric';
    const String departureTime = 'now';
    // const String trafficModel = 'best_guess';
    String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origins&destinations=$destinations&key=$key&mode=$mode&language=$language&units=$units&departure_time=$departureTime';
    print('url: $url');
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    // print(response.body);
    var results = {
      'origins': json['origin_addresses'],
      'destinations': json['destination_addresses'],
      'distances': json['rows'].map((row) {
        if (row['elements'] != null)
          return row['elements'].map((element) {
            if (element['distance'] != null)
              return element['distance']['value'];
          }).toList();
      }).toList(),
      'durations': json['rows'].map((row) {
        if (row['elements'] != null)
          return row['elements'].map((element) {
            if (element['duration_in_traffic'] != null)
              return element['duration_in_traffic']['value'];
          }).toList();
      }).toList(),
    };
    // print(results);
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
    if (response.statusCode != 200) {
      return {
        'status': 'Route Retrieval Failed',
        'error': response.body,
      };
    }

    var json = convert.jsonDecode(response.body);
    // print(json['geocoded_waypoints'].length);
    Duration time = Duration(
        seconds: (json['routes'][0]['legs']
            .map((leg) => leg['duration']['value'])
            .reduce((value, element) => value + element)));
    var results = {
      'status': 'Route Retrieval Successfull',
      'Fuel Stop Count': json['geocoded_waypoints'].length - 2,
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
      'distance': (json['routes'][0]['legs']
                  .map((leg) => leg['distance']['value'])
                  .reduce((value, element) => value + element) /
              1000)
          .round(),
      'duration':
          '${time.inHours}h:${time.inMinutes.remainder(60)}m:${time.inSeconds.remainder(60)}s',
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
    List<LatLng1> polylines = List.from(results['polylineDecoded'].map((e) {
      return LatLng1(e.latitude, e.longitude);
    }));
    // print(results);

    if (results['distance'] * 1000 > currentRange) {
      int segmentSize = (results['distance'] / 50) > 3000
          ? ((results['distance'] / 50) < (12000)
              ? (results['distance'] / 50).round()
              : (12000))
          : 3000;
      RouteSegment.segmentSize = segmentSize;
      List<RouteSegment> boxes = [];
      RouteSegment currentBox = RouteSegment(startPoint: polylines.first);
      String boxWaypoints = '';
      Map<String, dynamic> boxResults = {
        'origins': [],
        'destinations': [],
        'distances': [[]],
        'durations': [[]]
      };
      int boxCount = 0;
      for (final LatLng1 point in polylines) {
        if (currentBox.extend(point, RouteSegment.segmentSize)) {
          continue;
        } else {
          boxes.add(currentBox);
          // print('Box ${boxes.length} ${currentBox.bounds}');
          boxWaypoints +=
              '${currentBox.endPoint.latitude},${currentBox.endPoint.longitude}|';
          boxCount++;
          if (boxCount == 25) {
            var bresults = await getDistanceMatrix(origin, boxWaypoints);
            boxResults['origins'] = boxResults['origins'] + bresults['origins'];
            boxResults['destinations'] =
                boxResults['destinations'] + bresults['destinations'];
            boxResults['distances'][0] =
                boxResults['distances'][0] + bresults['distances'][0];
            boxResults['durations'][0] =
                boxResults['durations'][0] + bresults['durations'][0];
            boxCount = 0;
            boxWaypoints = '';
          }
          LatLng1 startPoint = RouteSegment.getSeed(currentBox.bounds, point);
          currentBox = RouteSegment(startPoint: startPoint);
          if (!currentBox.extend(point, RouteSegment.segmentSize)) {
            currentBox.extend(
                point, RouteSegment.calculateDistance(startPoint, point));
          }
        }
      }
      boxes.add(currentBox);
      boxWaypoints +=
          '${currentBox.endPoint.latitude},${currentBox.endPoint.longitude}';
      var bresults = await getDistanceMatrix(origin, boxWaypoints);
      boxResults['origins'] = boxResults['origins'] + bresults['origins'];
      boxResults['destinations'] =
          boxResults['destinations'] + bresults['destinations'];
      boxResults['distances'][0] =
          boxResults['distances'][0] + bresults['distances'][0];
      boxResults['durations'][0] =
          boxResults['durations'][0] + bresults['durations'][0];
      boxCount = 0;
      boxWaypoints = '';
      print(boxResults['distances'][0]);
      print('boxes: ${boxes.length}, segmentSize: $segmentSize');

      String waypoints = '&waypoints=optimize:true';
      // var boxResults = await getDistanceMatrix(origin, boxWaypoints);
      List<GasStation> finalGasStations = [];
      bool backtrack = false;
      for (int box = 0; box < boxes.length;) {
        int distCovered = boxResults['distances'][0][box];
        if ((distCovered < currentRange) && !backtrack) {
          // print('current box: $box, dist covered: $distCovered');
          box++;
          continue;
        } else {
          var gasStationsResponse =
              await getNearbyGasStation(boxes[box], segmentSize);
          List<GasStation> gasStations = gasStationsResponse['gasStations'];
          if (gasStations.isEmpty) {
            box--;
            backtrack = true;
            print(
                'no gas stations found, backtracking to $box, current range: $currentRange, dist covered: $distCovered, segment size: $segmentSize');
            if (box < 0 || boxes[box].refueled) {
              return {'status': 'Route not possible'};
            }
            continue;
          }
          String gasStationWaypoints = gasStationsResponse['waypoints'];
          var gasResults = await getDistanceMatrix(origin, gasStationWaypoints);
          gasStationWaypoints = '';
          for (int i = 0; i < gasStations.length && i < 10; i++) {
            print(gasResults['distances']);
            gasStations[i].toDistance = gasResults['distances'][0][i] ?? 0;
            gasStations[i].toDuration = gasResults['durations'][0][i] ?? 0;
            gasStationWaypoints += gasResults['distances'][0][i] < currentRange
                ? '${gasStations[i].placeID}|'
                : '';
          }
          // print(gasStations);
          gasStations = gasStations
              .where((element) =>
                  element.toDistance < currentRange && element.toDistance > 0)
              .toList();
          if (gasStations.isEmpty) {
            box--;
            backtrack = true;
            print(
                'backtrack to box $box, currentRange $currentRange, dist $distCovered, segmentSize $segmentSize');
            if (box < 0 || boxes[box].refueled) {
              return {'status': 'Route not possible'};
            }
            continue;
          }
          var gasStationResults =
              await getDistanceMatrix(gasStationWaypoints, destination);
          for (int i = 0; i < gasStations.length; i++) {
            gasStations[i].fromDistance = gasStationResults['distances'][i][0];
            gasStations[i].fromDuration = gasStationResults['durations'][i][0];
          }
          gasStations.sort((a, b) =>
              ((a.toDuration + a.fromDuration) * (1 + (10 / a.toDistance)))
                  .compareTo((b.toDuration + b.fromDuration) *
                      (1 + (100 / b.toDistance))));
          // print(gasStations);
          waypoints += '|${gasStations.first.placeID}';
          finalGasStations.add(gasStations.first);
          currentRange = gasStations.first.toDistance + maxRange;
          boxes[box].refueled = true;
          print(
              'box $box out of ${boxes.length} was refueled, currentRange $currentRange, dist $distCovered');
          box++;
          backtrack = false;
        }
      }
      // print('waypoints: $waypoints');
      var nresults = await getRoute(origin, destination + waypoints);
      nresults.addAll({
        'orignalDistance': results['distance'],
        'orignalDuration': results['duration'],
        'gasStations': finalGasStations,
      });
      return nresults;
    }
    return results;
  }
}

void main(List<String> args) {
  print(RouteSegment.calculateDistance(LatLng1(13, 81), LatLng1(13, 82)));
}
