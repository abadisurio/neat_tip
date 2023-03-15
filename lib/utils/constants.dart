import 'package:flutter_local_notifications/flutter_local_notifications.dart';

RegExp regexPlate = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{0,3}$');

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);
