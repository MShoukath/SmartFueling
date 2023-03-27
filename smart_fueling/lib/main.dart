import 'dart:async';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import './widgets/location.dart';
import './widgets/metrics.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> controllerMap =
      Completer<GoogleMapController>();

  loc.Location location = loc.Location();

  LatLng currentUserLocation = LatLng(13.0827, 80.2707);
  CameraPosition _userCamera = CameraPosition(target: LatLng(13.0827, 80.2707));

  LatLng fromLocation = LatLng(13.0827, 80.2707);
  bool fromLocationSelected = false;
  LatLng toLocation = LatLng(13.0827, 80.2707);
  bool toLocationSelected = false;

  setMarkerCallback(
      {LatLng markerPosition = const LatLng(13.0827, 80.2707),
      String markerType = 'from',
      bool markerSelected = false}) {
    setState(() {
      if (markerType == 'from') {
        fromLocation = markerPosition;
        fromLocationSelected = markerSelected;
      } else if (markerType == 'to') {
        toLocation = markerPosition;
        toLocationSelected = markerSelected;
      }
    });
  }

  moveToUser() async {
    final GoogleMapController controller = await controllerMap.future;
    setState(() {
      controller.animateCamera(
          CameraUpdate.newCameraPosition(_userCamera = CameraPosition(
        target: currentUserLocation,
        zoom: 16,
      )));
    });
  }

  Future<void> _enableLocationService({required loc.Location location}) async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;
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
    ;
    _locationData = await location.getLocation();

    moveToUser();
  }

  @override
  void initState() {
    _enableLocationService(location: location);
    super.initState();
    location.onLocationChanged.listen((loc.LocationData currentLocation) async {
      // Use current location
      final GoogleMapController controller = await controllerMap.future;
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
          title: Text('Smart Fueling'),
          actions: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.account_circle_rounded))
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
            onMapCreated: (controller) => {controllerMap.complete(controller)},
            markers: {
              Marker(
                markerId: MarkerId('currentLocation'),
                position: currentUserLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                visible: false,
              ),
              Marker(
                markerId: MarkerId('fromLocation'),
                position: fromLocation,
                icon: BitmapDescriptor.defaultMarker,
                visible: fromLocationSelected,
              ),
              Marker(
                markerId: MarkerId('toLocation'),
                position: toLocation,
                icon: BitmapDescriptor.defaultMarker,
                visible: toLocationSelected,
              )
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Locate(
                setMarker: setMarkerCallback,
              ),
              Metrics(),
            ],
          )
        ]),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 60.0),
          child: FloatingActionButton(
            child: Icon(Icons.my_location_outlined),
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

