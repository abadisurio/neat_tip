// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neat_tip/bloc/camera.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/utils/firebase.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/introduction.dart';

class Initialization extends StatefulWidget {
  final RouteObserver routeObserver;
  const Initialization({super.key, required this.routeObserver});

  @override
  State<Initialization> createState() => _InitializationState();
}

class _InitializationState extends State<Initialization> {
  bool isInitializing = true;

  late List<CameraDescription> cameras;

  late NeatTipDatabase database;
  // late A database;

  Future<User?> initialization() async {
    await AppFirebase.initializeFirebase();
    // await FirebaseAuth.instance.signOut();
    database =
        await $FloorNeatTipDatabase.databaseBuilder('database.db').build();
    cameras = await availableCameras();

    User? user = FirebaseAuth.instance.currentUser;
    initializeContexts();
    FlutterNativeSplash.remove();
    return user;
  }

  initializeContexts() {
    BlocProvider.of<CameraCubit>(context).setCameraList(cameras);
    BlocProvider.of<RouteObserverCubit>(context)
        .setRouteObserver(widget.routeObserver);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initialization(),
        builder: ((context, snapshot) {
          print('siniw');
          print(snapshot.data);

          // if (snapshot.data != null) {
          //   Navigator.of(context).pushReplacementNamed('/home');
          // }
          if (snapshot.data != null) return const Home();

          return const Introduction();
        }));
  }
}
