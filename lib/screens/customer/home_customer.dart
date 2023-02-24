import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/transaction_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/models/transactions.dart';
import 'package:neat_tip/screens/reservation_list.dart';
import 'package:neat_tip/widgets/carousel.dart';
import 'package:neat_tip/widgets/dashboard_menu.dart';

class HomeCustomer extends StatelessWidget {
  const HomeCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    seeMoreTransaction() {
      log('message');
      Navigator.pushNamed(context, '/transactions');
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            const Carousel(),
            const SizedBox(
              height: 16,
            ),
            const DashboardMenu(),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(' Terbaru'),
                TextButton(
                    style: const ButtonStyle(
                        visualDensity:
                            VisualDensity(vertical: -3, horizontal: -1)),
                    onPressed: seeMoreTransaction,
                    child: const Text('Lihat Semua')),
              ],
            ),
            const Divider(
              // height: 1,
              // height: 0,
              thickness: 2,
            ),
            BlocBuilder<ReservationsListCubit, List<Reservation>>(
                builder: (context, reservationList) {
              if (reservationList.isEmpty) {
                return const Center(child: Text('Belum ada transaksi!'));
              }
              log('reservationList ${reservationList.first.toJson()}');
              return ListView.builder(
                  itemCount: reservationList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
                    final item = reservationList[index];
                    return Card(
                      elevation: 0,
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () {},
                        // dense: true,
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.motorcycle,
                          ),
                        ),
                        title: Text(item.plateNumber),
                        subtitle: Text(DateFormat('EEEE d')
                            .format(DateTime.parse(item.timeCheckedIn ?? ''))),
                        trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (item.charge ?? 0).toString(),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Text(
                                item.status ?? '',
                                style: Theme.of(context).textTheme.caption,
                              )
                            ]),
                      ),
                    );
                  }));
            })
          ],
        ),
      ),
    );
  }
}
