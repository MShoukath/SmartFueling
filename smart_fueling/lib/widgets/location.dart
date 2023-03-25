import 'package:flutter/material.dart';

class Location extends StatefulWidget {
  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            decoration: InputDecoration(
                labelText: 'Starting Location',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20))),
        
          ),
          SizedBox(
            height: 5,
          ),
          TextField(
            decoration: InputDecoration(
                labelText: 'Enter Destination',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20))),
          ),
          TextButton(onPressed: () {}, child: Text('Go'))
        ],
      ),
    );
  }
}
