import 'dart:async';

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

  CameraPosition _userCamera = CameraPosition(target: LatLng(13.0827, 80.2707));

  loc.Location location = loc.Location();

  LatLng currentLocation = LatLng(13.0827, 80.2707);

  Future<void> _getUserLocation({required loc.Location location}) async {
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
    _locationData = await location.getLocation();
    print('Latitude & Lng of device :$_locationData.latitude');

    final GoogleMapController controller = await controllerMap.future;
    setState(() {
      currentLocation =
          LatLng(_locationData.latitude!, _locationData.longitude!);
      print('Latitude cur:${currentLocation.latitude}');
      print('Longitude cur:${currentLocation.longitude}');

      controller.animateCamera(CameraUpdate.newCameraPosition(
          _userCamera = CameraPosition(target: currentLocation)));
    });
  }

  @override
  void initState() {
    _getUserLocation(location: location);
    super.initState();
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
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: MarkerId('currentLocation'),
                position: currentLocation,
              )
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Locate(),
              Metrics(),
            ],
          )
        ]));
  }
}

//Attaining Device location

