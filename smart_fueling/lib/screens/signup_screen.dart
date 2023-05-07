import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartfueling/main.dart';
import 'package:smartfueling/screens/login_screen.dart';
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
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _mileage = TextEditingController();
  final TextEditingController _tankcapacity = TextEditingController();

  TextFormField inputField(
      String text, bool isPasswordType, TextEditingController controller) {
    return TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        obscureText: isPasswordType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          hintText: text,
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ));
  }

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
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              //Gets Email
              inputField("User Name", false, _userName),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value!)) {
                      return 'Enter Correct email';
                    }
                  },
                  controller: _userEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    hintText: 'Email ID',
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  )),
              const SizedBox(height: 10),
              //Gets Pass
              TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.length < 6) {
                      return 'Password must be more than 6 characters';
                    }
                  },
                  obscureText: true,
                  controller: _userPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    hintText: 'Password',
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  )),
              const SizedBox(
                height: 10,
              ),
              inputField("Mileage", false, _mileage),
              const SizedBox(
                height: 10,
              ),
              inputField("Tank Capacity", false, _tankcapacity),

              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _userEmail.text,
                              password: _userPassword.text);
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final uid = user.uid;
                        user.updateDisplayName(_userName.text);
                        CollectionReference userData =
                            FirebaseFirestore.instance.collection('Users');
                        userData.add({
                          'user_name': _userName.text,
                          'user_id': uid,
                          'email_id': _userEmail.text,
                          'password': _userPassword.text,
                          'mileage': _mileage.text,
                          'tank_capacity': _tankcapacity.text,
                        });
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInScreen()));
                    } on FirebaseAuthException catch (e) {
                      print(e.code);
                    }
                  },
                  child: Text('Sign Up')),
            ],
          ),
        ),
      ),
    );
  }
}
