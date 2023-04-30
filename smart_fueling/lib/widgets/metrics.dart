import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Metrics extends StatefulWidget {
  const Metrics({super.key});

  @override
  State<Metrics> createState() => _MetricsState();
}

class _MetricsState extends State<Metrics> {
  String fuelLeft = '0';

  Widget fuelLevel() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Sensor/distance");
    ref.onValue.listen((event) {
      setState(() {
        fuelLeft = event.snapshot.value.toString();
      });
    });
    return Text(" Ltrs:$fuelLeft");
  }

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(children: [
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.route_outlined),
                  Text('0.0'),
                ],
              ),
              Text('Estimated Range'),
              SizedBox(height: 5),
            ]),
            Column(children: [
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.local_gas_station_outlined),
                  FutureBuilder(
                      future: Firebase.initializeApp(),
                      builder: ((BuildContext context, snapshot) {
                        print(snapshot);
                        if (snapshot.hasError) {
                          return Text("Error");
                        } else if (snapshot.hasData) {
                          return fuelLevel();
                        } else {
                          return CircularProgressIndicator();
                        }
                      })),
                ],
              ),
              const Text('Fuel Level'),
              SizedBox(height: 5),
            ])
          ],
        ),
      ),
    );
  }
}
