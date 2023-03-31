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
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(children: const [
              SizedBox(height: 5),
              Icon(Icons.route_outlined),
              Text('Estimated Range'),
              Text('0.0'),
              SizedBox(
                height: 5,
              ),
            ]),
            Column(children: const [
              SizedBox(height: 5),
              Icon(Icons.local_gas_station_outlined),
              Text('Mileage'),
              Text('0.0'),
              SizedBox(height: 5),
            ])
          ],
        ),
      ),
    );
  }
}
