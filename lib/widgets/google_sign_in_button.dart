// ignore_for_file: avoid_print

// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/neattip_user.dart';

// import 'package:neat_tip/utils/firebase.dart';
class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final bool isSignUp;
  const GoogleSignInButton({super.key, this.onSuccess, required this.isSignUp});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final NeatTipUserCubit neatTipUserCubit = context.read<NeatTipUserCubit>();
    // final navigator = Navigator.of(context);
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
              try {
                setState(() {
                  _isSigningIn = true;
                });
                await Navigator.pushNamed(context, '/state_loading',
                    arguments: () async {
                  await neatTipUserCubit.signInGoogle();
                  log('widget.isSignUp ${widget.isSignUp}');
                  if (widget.isSignUp) {
                    await neatTipUserCubit.addUserToFirestore();
                  }
                });
                // final User? user = await AppFirebase.signInWithGoogle();
                setState(() {
                  _isSigningIn = false;
                });
                // print(user);
                if (widget.onSuccess != null) {
                  widget.onSuccess!();
                }
                // navigator.pop();
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
