import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neat_tip/bloc/camera.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/screens/auth_screen.dart';
import 'package:neat_tip/screens/explore_spot.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/initialization.dart';
import 'package:neat_tip/screens/profile.dart';
import 'package:neat_tip/screens/vehicle_add.dart';
import 'package:neat_tip/screens/vehicle_list.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  log('cameras $cameras');
  // Get a specific camera from the list of available cameras.
  // final firstCamera = cameras;

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // runApp(MyApp(
  //   cameras: cameras,
  // ));
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<CameraCubit>(
          create: (BuildContext context) => CameraCubit()),
      BlocProvider<RouteObserverCubit>(
          create: (BuildContext context) => RouteObserverCubit()),
    ],
    child: MyApp(
      cameras: cameras,
    ),
  ));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CameraCubit>(context).setCameraList(cameras);
    BlocProvider.of<RouteObserverCubit>(context)
        .setRouteObserver(routeObserver);
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
      home: const Initialization(),
    );
  }
}
