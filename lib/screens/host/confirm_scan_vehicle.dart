import 'dart:developer';

import 'package:flutter/material.dart';

class ConfirmScanVehicle extends StatefulWidget {
  const ConfirmScanVehicle({Key? key}) : super(key: key);

  @override
  State<ConfirmScanVehicle> createState() => _ConfirmScanVehicleState();
}

class _ConfirmScanVehicleState extends State<ConfirmScanVehicle> {
  late Map<String, dynamic> argument;
  List<String> scannedVehicleList = [];

  _getArgument() async {
    log('argument $argument');
    setState(() {
      scannedVehicleList = argument["scannedVehicleList"];
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _getArgument());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
            {};
    return WillPopScope(
      onWillPop: () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/homeroot', (route) => false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(),
        body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scannedVehicleList.length,
            itemBuilder: ((context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(scannedVehicleList[index]),
                ),
              );
            })),
      ),
    );
  }
}
