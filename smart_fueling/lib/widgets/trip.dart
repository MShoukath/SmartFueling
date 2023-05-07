import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  final userStream = FirebaseFirestore.instance
      .collection("Users")
      .doc("miGuCBf7WykNseRyKR38")
      .collection("Trips")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: StreamBuilder(
          stream: userStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Connection error');
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading......');
            } else {
              var docs = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(docs[index]['route']),
                      subtitle: Text(docs[index]['mileage']),
                    );
                  });
            }
          }),
    );
    // );
  }
}
