import 'package:flutter/cupertino.dart';
import 'package:neat_tip/screens/auth_screen.dart';
import 'package:neat_tip/screens/home_root.dart';
import 'package:neat_tip/screens/reservation_list.dart';
import 'package:neat_tip/screens/wallet.dart';
import 'package:neat_tip/screens/explore_spot.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/introduction.dart';
import 'package:neat_tip/screens/permission_window.dart';
import 'package:neat_tip/screens/profile.dart';
import 'package:neat_tip/screens/transaction_list.dart';
import 'package:neat_tip/screens/vehicle_add.dart';
import 'package:neat_tip/screens/vehicle_list.dart';

Route<dynamic>? routeGenerator(RouteSettings settings) {
  switch (settings.name) {
    case '/intro':
      return CupertinoPageRoute(
          builder: (_) => const Introduction(), settings: settings);
    case '/permission':
      return CupertinoPageRoute(
          builder: (_) => const PermissionWindow(), settings: settings);
    case '/explorespot':
      return CupertinoPageRoute(
          builder: (_) => const ExploreSpot(), settings: settings);
    case '/auth':
      return CupertinoPageRoute(
          builder: (_) => const AuthScreen(), settings: settings);
    case '/home':
      return CupertinoPageRoute(
          builder: (_) => const Home(), settings: settings);
    case '/homeroot':
      return CupertinoPageRoute(
          builder: (_) => const HomeRoot(), settings: settings);
    case '/homehost':
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
    case '/wallet':
      return CupertinoPageRoute(
          builder: (_) => const Wallet(), settings: settings);
    case '/transactions':
      return CupertinoPageRoute(
          builder: (_) => const TransactionList(), settings: settings);
    case '/reservations':
      return CupertinoPageRoute(
          builder: (_) => const ReservationList(), settings: settings);
  }
  return null;
}
