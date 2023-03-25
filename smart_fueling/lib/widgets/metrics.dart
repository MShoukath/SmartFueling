import 'package:flutter/material.dart';

class Metrics extends StatefulWidget {
  const Metrics({super.key});

  @override
  State<Metrics> createState() => _MetricsState();
}

class _MetricsState extends State<Metrics> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(children: [
            Icon(Icons.route_outlined),
            Text('Estimated Range'),
            Text('0.0')
          ]),
          Column(children: [
            Icon(Icons.local_gas_station_outlined),
            Text('Mileage'),
            Text('0.0')
          ])
        ],
      ),
    );
  }
}
