import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/screens/reservation_detail.dart';
import 'package:neat_tip/utils/date_time_to_string.dart';
import 'package:neat_tip/widgets/carousel.dart';
import 'package:neat_tip/widgets/dashboard_menu.dart';
import 'package:neat_tip/widgets/peek_and_pop_able.dart';
import 'package:skeletons/skeletons.dart';

class HomeCustomer extends StatelessWidget {
  const HomeCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    seeMoreTransaction() {
      log('message');
      Navigator.pushNamed(context, '/reservations');
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
            BlocBuilder<ReservationsListCubit, List<Reservation>?>(
                builder: (context, reservationList) {
              // log('reservationList $reservationList');
              if (reservationList == null) {
                return SizedBox(height: 500, child: SkeletonListView());
              }
              if (reservationList.isEmpty) {
                return const Center(child: Text('Belum ada transaksi!'));
              }
              // log('reservationList ${reservationList.first.toJson()}');
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
                      child: PeekAndPopable(
                        onTapChild: () {
                          Navigator.pushNamed(context, '/reservation_detail',
                              arguments:
                                  ReservationArgument(reservationId: item.id));
                        },
                        onTap: () {
                          Navigator.pushNamed(context, '/reservation_detail',
                              arguments:
                                  ReservationArgument(reservationId: item.id));
                        },
                        childToPeek: ReservationDetail(
                            reservationArgument:
                                ReservationArgument(reservationId: item.id)),
                        actions: [
                          {
                            "name": "Hapus",
                            "icon": Icons.delete,
                            "color": Colors.red,
                            "onTap": () {}
                          },
                          // {
                          //   "name": "Ubah",
                          //   "icon": Icons.edit,
                          //   "color": Colors.white,
                          //   "onTap": () {}
                          // },
                        ],
                        child: ListTile(
                          // dense: true,
                          leading: const CircleAvatar(
                            child: Icon(
                              Icons.motorcycle,
                            ),
                          ),
                          title: Text(item.spotName ?? ''),
                          subtitle: Text(item.plateNumber),
                          trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Rp${(item.charge ?? 0)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  item.status ?? '',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Text(
                                  dateTimeToString(item.timeCheckedIn ?? ''),
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ]),
                        ),
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
