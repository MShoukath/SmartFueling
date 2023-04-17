import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartfueling/screens/login_screen.dart';
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
      home: SignInScreen(),
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

  // Set<Marker> _mapMarkers = {};

  setMarkerCallback(
      {LatLng markerPosition = const LatLng(13.0827, 80.2707),
      String markerType = 'from',
      bool markerVisible = false}) async {
    setState(() {
      if (markerType == 'from') {
        fromLocation = markerPosition;
        fromLocationSelected = markerVisible;
      } else if (markerType == 'to') {
        toLocation = markerPosition;
        toLocationSelected = markerVisible;
      }
    });
    List<LatLng> markerList = [];
    if (fromLocationSelected) markerList.add(fromLocation);
    if (toLocationSelected) markerList.add(toLocation);
    markerList.add(currentUserLocation);
    if (markerList.length > 1) {
      final GoogleMapController controller = await controllerMap.future;
      controller.animateCamera(
          CameraUpdate.newLatLngBounds(boundsFromLatLngList(markerList), 110));
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
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Smart Fueling'),
          actions: [
            IconButton(
                onPressed: () {},
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
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: currentUserLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  visible: false,
                ),
                Marker(
                  markerId: const MarkerId('fromLocation'),
                  position: fromLocation,
                  icon: BitmapDescriptor.defaultMarker,
                  visible: fromLocationSelected,
                ),
                Marker(
                  markerId: const MarkerId('toLocation'),
                  position: toLocation,
                  icon: BitmapDescriptor.defaultMarker,
                  visible: toLocationSelected,
                )
              }),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Locate(
                setMarker: setMarkerCallback,
                userLocation: currentUserLocation,
              ),
              const Metrics(),
            ],
          )
        ]),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 60.0),
          child: FloatingActionButton(
            tooltip: 'Get Current Location',
            elevation: 8,
            onPressed: () {
              moveToUser();
            },
            child: const Icon(Icons.my_location_outlined),
          ),
        ));
  }
}

//Attaining Device location
