import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';

Future<void> sendFcmNotification(String customerId, String plateNumber,
    {String spotName = 'Kurnia Motor'}) async {
  // final function = FirebaseFunctions.instance;
  // function.useFunctionsEmulator('127.0.0.1', 5001);
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('sendNotification');
  final results = await callable.call({
    'customerId': customerId,
    'plateNumber': plateNumber,
    'spotName': spotName
  });
  String fruit = results.data;
  log('fruit $fruit');
}
