// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartfueling/screens/login_screen.dart';
// import 'package:smartfueling/screens/signup_screen.dart';
import 'package:smartfueling/screens/user_profile.dart';
import 'package:smartfueling/services/directions_api.dart';
import 'package:smartfueling/widgets/trip.dart';
import './widgets/location.dart';
import './widgets/metrics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Fueling',
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> controllerMap =
      Completer<GoogleMapController>();

  LatLng currentUserLocation = const LatLng(13.0827, 80.2707);
  LatLng fromLocation = const LatLng(13.0827, 80.2707);
  bool fromLocationSelected = false;
  LatLng toLocation = const LatLng(13.0827, 80.2707);
  bool toLocationSelected = false;
  // late GoogleMapController finalController;

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  // Set<Marker> _mapMarkers = {};
  Widget gasList = const SizedBox(
    height: 0,
  );

  setMarkerCallback(
      {LatLng markerPosition = const LatLng(13.0827, 80.2707),
      String markerType = 'from',
      bool markerVisible = false,
      Map<String, dynamic> directionsResponse = const {}}) async {
    // print('hi');
    setState(() {
      if (directionsResponse.isNotEmpty) {
        _polylines.clear();
        _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            visible: true,
            points: directionsResponse['polylineDecoded'],
            width: 3,
            color: Colors.blue));
        _markers.clear();
        _markers.add(Marker(
            markerId: const MarkerId('from'),
            position: directionsResponse['startLocation'],
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet)));
        for (int i = 1; i < directionsResponse['waypoints'].length - 1; i++) {
          _markers.add(Marker(
              markerId: MarkerId(directionsResponse['waypoints'][i].toString()),
              position: directionsResponse['waypoints'][i],
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen)));
        }
        _markers.add(Marker(
            markerId: const MarkerId('to'),
            position: directionsResponse['endLocation'],
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed)));

        gasList = directionsResponse['gasStations'] != null
            ? Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: DraggableScrollableSheet(
                    // expand: false,
                    initialChildSize: 0.14,
                    minChildSize: 0.14,
                    maxChildSize: (0.14 * (_markers.length)) > 1
                        ? 0.5
                        : 0.14 * (_markers.length),
                    builder: ((context, scrollController) {
                      return Container(
                        color: Colors.white,
                        child: ListView.builder(
                            itemCount:
                                directionsResponse['gasStations'].length + 1,
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(children: [
                                  const SizedBox(
                                    width: 50.0,
                                    child: Divider(
                                      thickness: 5,
                                    ),
                                  ),
                                  Text(
                                      'Travel Distance: ${directionsResponse['distance']}Km\nTravel Time: ${directionsResponse['duration']}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                ]);
                              } else {
                                return Card(
                                  // color: Colors.grey[200],
                                  child: ListTile(
                                    // contentPadding: EdgeInsets.only(bottom: 10.0),
                                    // tileColor: Colors.grey[200],
                                    leading: const Icon(
                                      Icons.local_gas_station_outlined,
                                      color: Colors.green,
                                    ),
                                    title: Text(
                                        directionsResponse['gasStations']
                                                [index - 1]
                                            .name),
                                    subtitle: Text(
                                        directionsResponse['gasStations']
                                                [index - 1]
                                            .address),
                                    trailing: Text(
                                        '${(directionsResponse['gasStations'][index - 1].toDistance / 1000).round()}Km'),
                                  ),
                                );
                              }
                            }),
                      );
                    })),
              )
            : SizedBox(
                height: 0,
              );
      } else if (markerType == 'from') {
        fromLocation = markerPosition;
        fromLocationSelected = markerVisible;
        _markers.clear();
        _polylines.clear();
        _markers.add(Marker(
            markerId: const MarkerId('from'),
            position: fromLocation,
            visible: markerVisible,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet)));
        gasList = const SizedBox(
          height: 0,
        );
      } else if (markerType == 'to') {
        toLocation = markerPosition;
        toLocationSelected = markerVisible;
        _polylines.clear();
        var fromMarker = _markers.firstWhere(
            (element) => element.markerId == const MarkerId('from'));
        _markers.clear();
        _markers.add(fromMarker);
        gasList = const SizedBox(
          height: 0,
        );
      }
    });
    List<LatLng> markerList = [];
    if (fromLocationSelected) markerList.add(fromLocation);
    if (toLocationSelected) markerList.add(toLocation);
    markerList.add(currentUserLocation);
    var bounds = directionsResponse.isEmpty
        ? boundsFromLatLngList(markerList)
        : directionsResponse['bounds'];
    if (markerList.length > 1) {
      final GoogleMapController controller = await controllerMap.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 110));
      controller.dispose();
    } else {
      moveToUser();
    }
  }

  static LatLngBounds boundsFromLatLngList(List<LatLng> markers) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in markers) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  moveToUser() async {
    final GoogleMapController controller = await controllerMap.future;
    setState(() {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: currentUserLocation,
        zoom: 16,
      )));
    });
    controller.dispose();
  }

  Future<void> _enableLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // _locationData = await location.getLocation();

    moveToUser();
  }

  @override
  void initState() {
    _enableLocationService();
    super.initState();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 40,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      position ?? const LatLng(13.0827, 80.2707);
      setState(() {
        currentUserLocation = LatLng(position!.latitude, position.longitude);
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // finalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Smart Fueling'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserProfile()));
                },
                icon: const Icon(Icons.account_circle_rounded))
          ],
        ),
        body: Stack(children: [
          GoogleMap(
              // myLocationButtonEnabled: true,
              // trafficEnabled: true,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: currentUserLocation,
                zoom: 16,
              ),
              onMapCreated: (controller) =>
                  {controllerMap.complete(controller)},
              markers: _markers,
              polylines: _polylines),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Locate(
                setMarker: setMarkerCallback,
                userLocation: currentUserLocation,
              ),
              Column(
                children: [
                  gasList,
                  Metrics(),
                ],
              ),
            ],
          )
        ]),
        floatingActionButton: _polylines.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 60.0),
                child: FloatingActionButton(
                  tooltip: 'Get Current Location',
                  elevation: 8,
                  onPressed: () {
                    moveToUser();
                  },
                  child: const Icon(Icons.my_location_outlined),
                ),
              )
            : const SizedBox(
                height: 0,
              ));
  }
}

//Attaining Device location
