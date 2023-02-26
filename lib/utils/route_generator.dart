import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/screens/auth_screen.dart';
import 'package:neat_tip/screens/host/confirm_scan_vehicle.dart';
import 'package:neat_tip/screens/host/home_host.dart';
import 'package:neat_tip/screens/home_root.dart';
import 'package:neat_tip/screens/host/scan_vehicle.dart';
import 'package:neat_tip/screens/profile_edit.dart';
import 'package:neat_tip/screens/reservation_detail.dart';
import 'package:neat_tip/screens/reservation_list.dart';
import 'package:neat_tip/screens/sign_out.dart';
import 'package:neat_tip/screens/state_loading.dart';
import 'package:neat_tip/screens/vehicle_request.dart';
import 'package:neat_tip/screens/wallet.dart';
import 'package:neat_tip/screens/customer/explore_spot.dart';
import 'package:neat_tip/screens/customer/home_customer.dart';
import 'package:neat_tip/screens/introduction.dart';
import 'package:neat_tip/screens/permission_window.dart';
import 'package:neat_tip/screens/manage.dart';
import 'package:neat_tip/screens/transaction_list.dart';
import 'package:neat_tip/screens/customer/vehicle_add.dart';
import 'package:neat_tip/screens/customer/vehicle_list.dart';

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
    case '/vehiclelist':
      return CupertinoPageRoute(
          builder: (_) => const VehicleList(), settings: settings);
    case '/vehicle_add':
      return CupertinoPageRoute(
          builder: (_) => const VehicleAdd(), settings: settings);
    case '/vehicle_request':
      return CupertinoPageRoute(
          builder: (_) => const VehicleRequest(), settings: settings);
    case '/scan_vehicle':
      return CupertinoPageRoute(
          builder: (_) => const ScanVehicle(), settings: settings);
    case '/confirm_scan_vehicle':
      return CupertinoPageRoute(
          builder: (_) => const ConfirmScanVehicle(), settings: settings);
    case '/profile':
      return CupertinoPageRoute(
          builder: (_) => const Manage(), settings: settings);
    case '/profileedit':
      return CupertinoPageRoute(
          builder: (_) => const ProfileEdit(), settings: settings);
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
    case '/reservation_detail':
      return CupertinoPageRoute(
          builder: (_) => const ReservationDetail(), settings: settings);
    case '/home':
      return MaterialPageRoute(
          builder: (_) => const HomeCustomer(), settings: settings);
    case '/homeroot':
      return MaterialPageRoute(
          builder: (_) => const HomeRoot(), settings: settings);
    case '/homehost':
      return MaterialPageRoute(
          builder: (_) => const HomeHost(), settings: settings);
    case '/state_loading':
      return PageRouteBuilder(
          transitionsBuilder: (ctx, anim1, anim2, child) {
            return BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 7 * anim1.value, sigmaY: 7 * anim1.value),
                child: Opacity(opacity: anim1.value, child: child));
          },
          opaque: false,
          pageBuilder: (context, anim1, anim2) => const StateLoading(),
          settings: settings);
    case '/signout':
      return PageRouteBuilder(
          transitionsBuilder: (ctx, anim1, anim2, child) {
            return BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 7 * anim1.value, sigmaY: 7 * anim1.value),
                child: Opacity(opacity: anim1.value, child: child));
          },
          opaque: false,
          pageBuilder: (context, anim1, anim2) => const SignOut(),
          settings: settings);
  }
  return null;
}
