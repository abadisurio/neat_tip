import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neat_tip/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeFCM() async {
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // log('message ${await messaging.getToken()}');
  // String? fcmToken = await _getFcmToken();
  log('siniii');
  await reloadFcmToken();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('mipmap/ic_launcher');
// final DarwinInitializationSettings initializationSettingsDarwin =
//     DarwinInitializationSettings(
//         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
// final LinuxInitializationSettings initializationSettingsLinux =
//     LinuxInitializationSettings(
//         defaultActionName: 'Open notification');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   log('messageww ${message.notification!.body}');
  //   //   RemoteNotification? notification = message.notification;
  //   //   AndroidNotification? android = message.notification?.android;

  //   //   // If `onMessage` is triggered with a notification, construct our own
  //   //   // local notification to show to users using the created channel.
  //   //   if (notification != null && android != null) {
  //   //     log('notification.hashCode ${notification.hashCode}');
  //   //     flutterLocalNotificationsPlugin.show(
  //   //         notification.hashCode,
  //   //         notification.title,
  //   //         notification.body,
  //   //         NotificationDetails(
  //   //           android: AndroidNotificationDetails(
  //   //             channel.id,
  //   //             channel.name,
  //   //             channel.description,
  //   //             icon: android.smallIcon,
  //   //             // other properties...
  //   //           ),
  //   //         ));
  //   //   }
  // });
}

Future<String?> reloadFcmToken() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  // await sharedPreferences.remove("fcmToken");
  final sharePrefFcm = sharedPreferences.getString("fcmToken");
  // Map<String, dynamic>? fcmToken = jsonDecode(sharePrefFcm );
  final String? token = await FirebaseMessaging.instance.getToken();
  log('fcmToken $sharePrefFcm');
  if (sharePrefFcm == null) {
    final firestore = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    log('uid $uid $token');
    if (token != null && uid != null) {
      final fcmTokenData = {
        'fcmToken': token,
        'timestamp': DateTime.now().toIso8601String()
      };
      // log('fcmTokenData.toString() ${fcmTokenData.toString()}');
      await sharedPreferences.setString('fcmToken', fcmTokenData.toString());
      await firestore
          .collection("fcmToken")
          .doc(uid)
          .set(fcmTokenData, SetOptions(merge: true));
    }
    return token;
    // return fcmToken;
  }
  return null;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  log("Handling a background message: ${message.messageId}");
}
