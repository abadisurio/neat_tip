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

  List<PageViewModel> listPagesViewModel = [
    PageViewModel(
        title: " ",
        bodyWidget: const Center(
          child: Text('hehehe'),
        )),
    PageViewModel(
        useScrollView: false,
        title: " ",
        bodyWidget: Column(
          children: [
            SizedBox(
                height: 300,
                width: 500,
                child: Card(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: PermissionWindow(
                    onAllowedAll: () {
                      // setState(() {
                      //   log('boleh');
                      // });
                    },
                  ),
                ))),
          ],
        )),
    PageViewModel(
        title: " ",
        bodyWidget: const Center(
          child: Text('hehehe'),
        )),
  ];

  setPermissionsAllowed() {
    setState(() {
      _isPermissionsAllowed = true;
    });
  }

  navigateToAuthPage() async {
    final isLoggedIn = await Navigator.pushNamed(context, '/auth') as bool;
    log('isLoggedIn $isLoggedIn');
    setState(() {
      _isLoggedIn = isLoggedIn;
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

  @override
  Widget build(BuildContext context) {
    // log('_isLoggedIn $_isLoggedIn');

    return SafeArea(
      child: IntroductionScreen(
        // canProgress: () {
        //   return true;
        // },
        // freeze: true,
        // pages: listPagesViewModel,
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
          const Center(
            child: Text('hehehe'),
          ),
          PermissionWindow(
            onAllowedAll: setPermissionsAllowed,
          ),
          Center(
            child: ElevatedButton(
              onPressed: navigateToAddVehiclePage,
              child: const Text('Tambah Kendaraan'),
            ),
          ),
          // const VehicleAdd()
        ],
        canProgress: (double page) {
          log('page $page');
          // if (!(page > 1 && !_isLoggedIn)) {
          //   return false;
          // } else if (!(page > 2 && !_isPermissionsAllowed)) {
          //   return false;
          // }
          return true;
        },
        // showNextButton: false,
        next: const Text("Lanjut"),
        allowImplicitScrolling: true,
        done: const Text("Mulai Neat Tip"),
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
