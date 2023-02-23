import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';

Future<void> sendFcmNotification() async {
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('sendNotification');
  final results = await callable();
  String fruit = results.data;
  log('fruit $fruit');
}
