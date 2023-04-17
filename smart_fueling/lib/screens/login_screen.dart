import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartfueling/main.dart';
import 'package:smartfueling/screens/signup_screen.dart';
//import 'package:user_auth/screens/home_screen.dart';
import 'package:smartfueling/widgets/logo.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
              'Log In',
              style: TextStyle(color: Colors.white, fontSize: 20),
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
            const SizedBox(height: 10),
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _userEmail.text, password: _userPassword.text)
                      .then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ));
                  }).onError((error, stackTrace) {
                    print('${error.toString()}');
                  });
                },
                child: Text('Log In')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Dont Have an account?',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen()));
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
