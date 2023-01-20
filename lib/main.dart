import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neat_tip/bloc/camera.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/introduction.dart';
import 'package:neat_tip/screens/loading_window.dart';
import 'package:neat_tip/screens/permission_window.dart';
import 'package:neat_tip/screens/suspend.dart';
import 'package:neat_tip/utils/firebase.dart';
import 'package:neat_tip/utils/route_generator.dart';
import 'package:neat_tip/utils/theme_data.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isNeedPermission = false;
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  late User? user;
  late List<CameraDescription> cameras;
  late NeatTipDatabase database;
  bool isAllAllowed = true;

  Future<void> initializeComponents() async {
    await AppFirebase.initializeFirebase();
    // await FirebaseAuth.instance.signOut();
    cameras = await availableCameras();
    isNeedPermission = await checkPermission();
    user = FirebaseAuth.instance.currentUser;
    database =
        await $FloorNeatTipDatabase.databaseBuilder('database.db').build();
  }

  Future<void> initializeBloc(BuildContext context) async {
    final blocDB = BlocProvider.of<VehicleListCubit>(context);
    BlocProvider.of<CameraCubit>(context).setCameraList(cameras);
    BlocProvider.of<RouteObserverCubit>(context)
        .setRouteObserver(routeObserver);
    blocDB.initializeDB(database);
    await blocDB.pullDataFromDB();
    // await Future.delayed(const Duration(milliseconds: 1000));
  }

  Future<bool> checkPermission() async {
    bool isAllAllowed = true;
    for (var service in serviceList) {
      final Permission permission = service['type'];
      final status = await permission.status;
      if (!status.isGranted) isAllAllowed = false;
    }
    return isAllAllowed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<CameraCubit>(
              create: (BuildContext context) => CameraCubit()),
          BlocProvider<RouteObserverCubit>(
              create: (BuildContext context) => RouteObserverCubit()),
          BlocProvider<VehicleListCubit>(
              create: (BuildContext context) => VehicleListCubit()),
        ],
        child: MaterialApp(
            title: 'Flutter Demo',
            navigatorObservers: [routeObserver],
            theme: getThemeData(),
            onGenerateRoute: routeGenerator,
            home: FutureBuilder(
              future: initializeComponents(),
              builder: (context, snapshot) {
                // FlutterNativeSplash.remove();
                // return LoadingWindow();
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingWindow();
                }
                return FutureBuilder(
                  future: initializeBloc(context),
                  builder: (context, snapshot) {
                    log('snapshot.connectionState ${snapshot.connectionState}');
                    if (snapshot.connectionState != ConnectionState.done) {
                      //  FlutterNativeSplash.remove();
                      return const LoadingWindow();
                    } else {
                      FlutterNativeSplash.remove();
                      if (user == null) {
                        return const Introduction();
                      } else if (!isNeedPermission) {
                        return const PermissionWindow();
                      }
                      return const Home();
                    }
                  },
                );
              },
            )));
  }
}
