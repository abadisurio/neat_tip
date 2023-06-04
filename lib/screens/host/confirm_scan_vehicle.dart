import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/service/fb_cloud_functions.dart';

class ConfirmScanVehicle extends StatefulWidget {
  final Map<String, String> plateList;
  const ConfirmScanVehicle({Key? key, required this.plateList})
      : super(key: key);

  @override
  State<ConfirmScanVehicle> createState() => _ConfirmScanVehicleState();
}

class _ConfirmScanVehicleState extends State<ConfirmScanVehicle> {
  _processVehicle() async {
    final reservationsListCubit = context.read<ReservationsListCubit>();
    final plate = widget.plateList;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final failedPlates = [];
    await Navigator.pushNamed(context, '/state_loading', arguments: () async {
      for (var element in plate.entries) {
        final reservation = Reservation(
            id: '',
            spotId: 'S1',
            spotName: 'Kurnia Motor',
            customerId: FirebaseAuth.instance.currentUser!.uid,
            hostUserId: uid ?? '',
            plateNumber: element.key,
            timeCheckedIn: DateTime.now().toIso8601String());
        try {
          final reservationData =
              await reservationsListCubit.addReservation(reservation);
          notifyRsvpAdded(reservationData);
          // await reservationsListCubit.addReservation(reservation);
          // await vehicleListCubit.add();
          log('hereeeeee');
        } catch (e) {
          failedPlates.add(element.key);
        }
      }
    });
    if (failedPlates.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Beberapa kendaraan tidak dapat ditambahkan: '),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [...failedPlates.map((e) => Text(e)).toList()],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/homeroot', (route) => route.isFirst);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scannedPlateList = widget.plateList;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Plat Nomor'),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scannedPlateList.length + 1,
          itemBuilder: ((context, index) {
            if (index == scannedPlateList.length) {
              return ElevatedButton(
                  onPressed: _processVehicle,
                  child: const Text('Proses Kendaraan'));
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(scannedPlateList.entries.elementAt(index).key),
              ),
            );
          })),
    );
  }
}
