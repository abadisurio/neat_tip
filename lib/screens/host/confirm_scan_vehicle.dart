import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/service/fb_cloud_functions.dart';

class ConfirmScanVehicle extends StatefulWidget {
  const ConfirmScanVehicle({Key? key}) : super(key: key);

  @override
  State<ConfirmScanVehicle> createState() => _ConfirmScanVehicleState();
}

class _ConfirmScanVehicleState extends State<ConfirmScanVehicle> {
  late Map<String, dynamic> argument;
  List<String> scannedVehicleList = [];

  _getArgument() async {
    setState(() {
      scannedVehicleList = argument["scannedVehicleList"];
    });
    log('argument $argument');
  }

  _processVehicle() async {
    final reservationsListCubit = context.read<ReservationsListCubit>();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await Navigator.pushNamed(context, '/state_loading', arguments: () async {
      for (var element in scannedVehicleList) {
        final reservation = Reservation(
            id: '',
            spotId: 'S1',
            hostUserId: uid ?? '',
            plateNumber: element,
            timeCheckedIn: DateTime.now().toIso8601String());
        await reservationsListCubit.addReservation(reservation);
        sendFcmNotification();
        // await reservationsListCubit.addReservation(reservation);
        // await vehicleListCubit.add();
        log('hereeeeee');
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Plat Nomor'),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scannedVehicleList.length + 1,
          itemBuilder: ((context, index) {
            if (index == scannedVehicleList.length) {
              return ElevatedButton(
                  onPressed: _processVehicle,
                  child: const Text('Proses Kendaraan'));
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(scannedVehicleList[index]),
              ),
            );
          })),
    );
  }
}
