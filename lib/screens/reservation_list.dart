import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/models/reservation.dart';

class ReservationList extends StatelessWidget {
  const ReservationList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationsListCubit, List<Reservation>>(
        builder: (context, reservationList) {
      log('reservationList $reservationList');
      return Scaffold(
          appBar: AppBar(),
          body: () {
            if (reservationList.isEmpty) {
              return const Center(
                child: Text('Kamu belum buat reservasi'),
              );
            } else {
              return ListView.builder(
                  itemCount: reservationList.length,
                  itemBuilder: ((context, index) {
                    if (reservationList.isEmpty) {
                      return const Center(
                        child: Text('Kamu belum melakukan reservasi'),
                      );
                    } else {
                      return const ListTile();
                    }
                  }));
            }
          }());
    });
  }
}
