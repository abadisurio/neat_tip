import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:neat_tip/models/reservation.dart';

Future<void> notifyRsvpAdded(Reservation reservation) async {
  // final function = FirebaseFunctions.instance;
  // function.useFunctionsEmulator('127.0.0.1', 5001);
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('notifyRsvpAdded');
  final results = await callable.call({
    'customerId': reservation.customerId,
    'plateNumber': reservation.plateNumber,
    'spotName': reservation.spotName,
    'reservationId': reservation.id
  });
  String fruit = results.data;
  log('fruit $fruit');
}

Future<void> notifyRsvpFinished(Reservation reservation) async {
  // final function = FirebaseFunctions.instance;
  // function.useFunctionsEmulator('127.0.0.1', 5001);
  log('reservation ${reservation.toJson()}');
  HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('sendNotification');
  await callable.call({
    'customerId': reservation.customerId,
    'plateNumber': reservation.plateNumber,
    'spotName': reservation.plateNumber,
    'reservationId': reservation.id,
    'spotId': reservation.spotId
  });
  // String fruit = results.data;
  // log('fruit $fruit');
}
