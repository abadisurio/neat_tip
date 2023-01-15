// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neat_tip/utils/firebase.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/introduction.dart';

class Initialization extends StatefulWidget {
  const Initialization({super.key});

  @override
  State<Initialization> createState() => _InitializationState();
}

class _InitializationState extends State<Initialization> {
  bool isInitializing = true;

  Future<User?> initialization() async {
    await AppFirebase.initializeFirebase();
    // FirebaseAuth.instance.signOut();
    User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) Navigator.of(context).pushReplacementNamed('/home');
    FlutterNativeSplash.remove();
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initialization(),
        builder: ((context, snapshot) {
          print('sini');
          print(snapshot.data);

          // if (snapshot.data != null) {
          //   Navigator.of(context).pushReplacementNamed('/home');
          // }
          if (snapshot.data != null) return const Home();

          return const Introduction();
        }));
  }
}
