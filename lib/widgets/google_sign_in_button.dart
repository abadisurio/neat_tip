// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/utils/firebase.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return _isSigningIn
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: () async {
              setState(() {
                _isSigningIn = true;
              });
              try {
                final User? user = await AppFirebase.signInWithGoogle();
                setState(() {
                  _isSigningIn = false;
                });
                print(user);
                navigator.pushNamedAndRemoveUntil('/home', (route) => false);
                // navigator.pop();
                // navigator.pushNamed('/home');
              } catch (e) {
                print(e);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Image(
                  image: AssetImage("assets/google_logo.png"),
                  height: 18.0,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Masuk dengan Google',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          );
  }
}
