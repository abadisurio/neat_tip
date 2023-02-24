import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/utils/date_time_to_string.dart';
import 'package:skeletons/skeletons.dart';

class ReservationList extends StatelessWidget {
  const ReservationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Reservasi')),
      body: BlocBuilder<ReservationsListCubit, List<Reservation>?>(
          builder: (context, reservationList) {
        return Skeleton(
          isLoading: reservationList == null,
          skeleton: SkeletonListView(),
          child: () {
            if (reservationList!.isEmpty) {
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
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, '/reservation_detail',
                            arguments: item.id);
                      },
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
                              style: Theme.of(context).textTheme.bodyText1,
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
                  );
                }));
          }(),
        );
      }),
    );
  }
}
