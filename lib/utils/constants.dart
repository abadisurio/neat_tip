import 'package:flutter_local_notifications/flutter_local_notifications.dart';

RegExp regexPlate =
    RegExp(r'^([A-Za-z0-9]{1,4})(\s|-)*([0-9]{1,5})(\s|-)*([A-Za-z]{0,3})$');

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);
