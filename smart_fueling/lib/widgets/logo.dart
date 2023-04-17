import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
          child: const SizedBox(
            width: 120,
            height: 120,
            child: Icon(
              Icons.local_gas_station_rounded,
              size: 100,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text('Smart Fueling',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 20,
            )),
      ],
    );
  }
}
