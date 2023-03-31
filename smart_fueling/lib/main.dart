import 'dart:async';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import './widgets/location.dart';
import './widgets/metrics.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Fueling',
      home: const HomePage(),
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

  loc.Location location = loc.Location();

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
          CameraUpdate.newLatLngBounds(boundsFromLatLngList(markerList), 120));
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

  Future<void> _enableLocationService({required loc.Location location}) async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    // _locationData = await location.getLocation();

    moveToUser();
  }

  @override
  void initState() {
    _enableLocationService(location: location);
    super.initState();
    location.onLocationChanged.listen((loc.LocationData currentLocation) async {
      // Use current location
      setState(() {
        currentUserLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
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
              ),
              const Metrics(),
            ],
          )
        ]),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 60.0),
          child: FloatingActionButton(
            child: const Icon(Icons.my_location_outlined),
            tooltip: 'Get Current Location',
            elevation: 8,
            onPressed: () {
              moveToUser();
            },
          ),
        ));
  }
}

//Attaining Device location

