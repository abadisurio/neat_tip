import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/models/reservation.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

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
                child: Text('Kamu belum buat transaksi'),
              );
            } else {
              return ListView.builder(
                  itemCount: reservationList.length,
                  itemBuilder: ((context, index) {
                    return const ListTile();
                  }));
            }
          }());
    });
  }
}
