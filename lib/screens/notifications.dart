import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/notification_list.dart';
import 'package:neat_tip/models/neattip_notification.dart';
import 'package:neat_tip/utils/date_time_to_string.dart';
import 'package:skeletons/skeletons.dart';

class Notifications extends StatelessWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationListCubit, List<NeatTipNotification>?>(
        builder: (context, neatTipNotification) {
      log('neatTipNotification $neatTipNotification');
      if (neatTipNotification == null) {
        return SkeletonListTile();
      }
      return ListView.builder(
          itemCount: neatTipNotification.length,
          itemBuilder: ((context, index) {
            final item = neatTipNotification.reversed.elementAt(index);
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.info_outline)),
              title: Text(item.title),
              subtitle: Text(dateTimeToString(item.createdAt)),
              // trailing: Text(dateTimeToString(item.createdAt)),
            );
          }));
    });
  }
}
