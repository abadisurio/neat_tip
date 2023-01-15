import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:neat_tip/screens/auth_screen.dart';
import 'package:neat_tip/screens/explore_spot.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/initialization.dart';
import 'package:neat_tip/screens/profile.dart';
import 'package:neat_tip/screens/vehicle_list.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
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
          case '/profile':
            return CupertinoPageRoute(
                builder: (_) => const Profile(), settings: settings);
          case '/explorespot':
            return CupertinoPageRoute(
                builder: (_) => const ExploreSpot(), settings: settings);
        }
        return null;
      },
      home: const Initialization(),
    );
  }
}
