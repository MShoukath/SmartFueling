import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartfueling/main.dart';
//import 'package:user_auth/screens/home_screen.dart';
import 'package:smartfueling/widgets/logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.greenAccent,
          Colors.deepPurple,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Logo(),
            const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
                controller: _userEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  hintText: 'Email ID',
                  contentPadding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxHeight: 50),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                )),
            const SizedBox(
              height: 10,
            ),
            TextField(
                obscureText: true,
                controller: _userPassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  hintText: 'Password',
                  contentPadding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxHeight: 50),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                )),
            ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _userEmail.text, password: _userPassword.text)
                      .then((value) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }).onError((error, stackTrace) {
                    print('Error ${error.toString()}');
                  });
                },
                child: Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
