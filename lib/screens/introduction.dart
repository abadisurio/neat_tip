import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:neat_tip/screens/permission_window.dart';
import 'package:neat_tip/screens/vehicle_add.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  bool _isPermissionsAllowed = false;
  bool _isLoggedIn = false;
  bool _isVehicleAdded = false;
  bool _isPageSuspended = false;

  navigateToAuthPage() async {
    final isLoggedIn = await Navigator.pushNamed(context, '/auth') as bool;
    log('isLoggedIn $isLoggedIn');
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isPageSuspended = !isLoggedIn;
    });
  }

  navigatoToPermissionPage() async {
    final isPermissionsAllowed =
        await Navigator.pushNamed(context, '/permission') as bool;
    log('isPermissionsAllowed $isPermissionsAllowed');
    //  PermissionWindow(
    //         onAllowedAll: setPermissionsAllowed,
    //       ),
    setState(() {
      _isPermissionsAllowed = isPermissionsAllowed;
      _isPageSuspended = !isPermissionsAllowed;
    });
  }

  navigateToAddVehiclePage() async {
    final isVehicleAdded =
        await Navigator.pushNamed(context, '/vehicleadd') as bool?;
    log('isVehicleAdded $isVehicleAdded');
    setState(() {
      _isVehicleAdded = isVehicleAdded ?? false;
    });
  }

  setSuspend(int page) {
    log('page $page');
    bool suspend = false;
    if (page < 2 && !_isLoggedIn) suspend = true;
    if (page < 3 && !_isPermissionsAllowed) suspend = true;
    if (page < 4 && !_isVehicleAdded) suspend = true;
    setState(() {
      _isPageSuspended = suspend;
    });
  }

  @override
  Widget build(BuildContext context) {
    log('_isPageSuspended $_isPageSuspended');
    // log('_isLoggedIn $_isLoggedIn');

    return SafeArea(
      child: IntroductionScreen(
        rawPages: [
          const Center(
            child: Text('hehehe'),
          ),
          Center(
            child: ElevatedButton(
              onPressed: navigateToAuthPage,
              child: const Text('Masuk'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: navigatoToPermissionPage,
              child: const Text('izin'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: navigateToAddVehiclePage,
              child: const Text('Tambah Kendaraan'),
            ),
          ),
        ],
        onChange: setSuspend,
        showNextButton: !_isPageSuspended,
        showDoneButton: _isVehicleAdded,
        next: const Text("Lanjut"),
        back: const Text("Kembali"),
        done: const Text("Mulai Neat Tip"),
        freeze: true,
        showBackButton: true,
        allowImplicitScrolling: false,
        // allowImplicitScrolling: true,
        onDone: () {
          // On button pressed
          // setState(() {

          // });
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        },
      ),
    );
  }
}
