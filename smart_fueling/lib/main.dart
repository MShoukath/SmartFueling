import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import './widgets/location.dart';
import './widgets/metrics.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Fueling',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            target: LatLng(
              13.0827,
              80.2707,
            ),
            zoom: 16,
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Location(),
              Metrics(),
            ],
          )
        ]));
  }
}
