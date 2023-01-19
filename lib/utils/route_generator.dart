import 'package:flutter/cupertino.dart';
import 'package:neat_tip/screens/auth_screen.dart';
import 'package:neat_tip/screens/explore_spot.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/profile.dart';
import 'package:neat_tip/screens/vehicle_add.dart';
import 'package:neat_tip/screens/vehicle_list.dart';

Route<dynamic>? routeGenerator(RouteSettings settings) {
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
}
