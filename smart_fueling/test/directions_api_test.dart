import 'package:flutter_test/flutter_test.dart';
import '../lib/services/directions_api.dart';

main() {
  group('Directions Services Tests', () {
    test('Testing calculate distance', () {
      expect(RouteSegment.calculateDistance(LatLng1(13, 81), LatLng1(13, 82)),
          54233);
    });
    var route =
        RouteSegment(startPoint: LatLng1(13, 81), endPoint: LatLng1(13, 82));
    test('Routesegment contains test', () {
      expect(route.contains(LatLng1(13, 81)), true);
    } //);
        );
    test('Gas Stations test', () {
      expect(
          GasStation(
                  name: 'name',
                  address: 'address',
                  location: LatLng1(13, 81),
                  placeID: 'placeID')
              .placeID,
          'placeID');
    });

    test('Route segment extend test', () {
      expect(route.extend(LatLng1(13, 83), 100000), false);
    });
    test('Route segment length test', () {
      expect(route.points.length, 1);
    });
  });
}
