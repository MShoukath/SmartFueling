import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartfueling/main.dart';
import 'package:smartfueling/screens/login_screen.dart';
import 'package:smartfueling/widgets/trip.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var name = " ";
  var email = " ";
  var userid = " ";
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      name = user.displayName.toString();
      email = user.email.toString();
      userid = user.uid;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.navigate_before),
        ),
        title: const Text("Profile"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.account_circle_outlined),
              title: Text('User Name : $name'),
            ),
            ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('EmailID : $email'),
            ),
            ListTile(
              leading: Icon(Icons.gas_meter_outlined),
              title: Text('Mileage : '),
            ),
            ListTile(
              leading: Icon(Icons.local_gas_station_outlined),
              title: Text('Tank Capacity :'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                },
                icon: Icon(Icons.logout_outlined),
                label: Text('Logout')),
            SizedBox(
              height: 10,
            ),
            Card(
                elevation: 6,
                child: Column(children: [
                  Text(
                    'History of Trips',
                    style: TextStyle(fontSize: 20),
                  ),
                  Trip()
                ])),
          ],
        ),
      ),
    );
  }
}
