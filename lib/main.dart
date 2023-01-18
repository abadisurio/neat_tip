import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neat_tip/bloc/camera.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/screens/auth_screen.dart';
import 'package:neat_tip/screens/explore_spot.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/initialization.dart';
import 'package:neat_tip/screens/introduction.dart';
import 'package:neat_tip/screens/profile.dart';
import 'package:neat_tip/screens/vehicle_add.dart';
import 'package:neat_tip/screens/vehicle_list.dart';
import 'package:neat_tip/utils/firebase.dart';

Future<void> main() async {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  late List<CameraDescription> cameras;
  late NeatTipDatabase database;

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await AppFirebase.initializeFirebase();
  // await FirebaseAuth.instance.signOut();
  database = await $FloorNeatTipDatabase.databaseBuilder('database.db').build();
  cameras = await availableCameras();

  User? user = FirebaseAuth.instance.currentUser;
  // initializeContexts();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<CameraCubit>(
          create: (BuildContext context) => CameraCubit()),
      BlocProvider<RouteObserverCubit>(
          create: (BuildContext context) => RouteObserverCubit()),
      BlocProvider<VehicleListCubit>(
          create: (BuildContext context) => VehicleListCubit()),
    ],
    child: MyApp(
        cameras: cameras,
        user: user,
        routeObserver: routeObserver,
        database: database),
  ));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final User? user;
  final RouteObserver routeObserver;
  final NeatTipDatabase database;
  const MyApp(
      {super.key,
      required this.cameras,
      required this.user,
      required this.routeObserver,
      required this.database});

  initializeBlocs(BuildContext context) {
    BlocProvider.of<CameraCubit>(context).setCameraList(cameras);
    BlocProvider.of<RouteObserverCubit>(context)
        .setRouteObserver(routeObserver);
    BlocProvider.of<VehicleListCubit>(context).initializeDB(database);
  }

  Future<void> initializeBlocsAsync(BuildContext context) async {
    await BlocProvider.of<VehicleListCubit>(context).pullDataFromDB();
  }

  @override
  Widget build(BuildContext context) {
    initializeBlocs(context);
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          toolbarHeight: 100,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(
            color: Colors.grey.shade800, //change your color here
          ),
          surfaceTintColor: Colors.grey.shade800,
          foregroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
          ),
        ),
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/auth':
            return CupertinoPageRoute(
                builder: (_) => const AuthScreen(), settings: settings);
          case '/home':
            return CupertinoPageRoute(
                builder: (_) => const Home(), settings: settings);
          case '/vehiclelist':
            return CupertinoPageRoute(
                builder: (_) => const VehicleList(), settings: settings);
          case '/vehicleadd':
            return CupertinoPageRoute(
                builder: (_) => const VehicleAdd(), settings: settings);
          case '/profile':
            return CupertinoPageRoute(
                builder: (_) => const Profile(), settings: settings);
          case '/spots':
            return CupertinoPageRoute(
                builder: (_) => const ExploreSpot(), settings: settings);
        }
        return null;
      },
      // home: BlocProvider(
      //   create: (_) => CameraCubit(),
      //   child: const Initialization(),
      //   // child: BlocProvider(child: const Initialization()),
      // ),
      // home: (() {
      //   if (user != null) return const Home();
      //   return const Introduction();
      // }()),
      home: FutureBuilder(
        future: initializeBlocsAsync(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            FlutterNativeSplash.remove();
            if (user != null) return const Home();
            return const Introduction();
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
