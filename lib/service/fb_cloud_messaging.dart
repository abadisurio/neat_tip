import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neat_tip/bloc/notification_list.dart';
import 'package:neat_tip/models/neattip_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  static String? idPush;
  static late NotificationListCubit? _cubit;
  static late Function? _runOpenedMessage;
  static late Function? _runOnMessage;
  static final StreamController<RemoteMessage> _messageStream =
      StreamController.broadcast();
  static Stream<RemoteMessage> get messagesStream => _messageStream.stream;
  static Function get onMessageOpenedHandler => _onMessageHandler;

  static Future _backgroundHandler(RemoteMessage message) async {
    log('bekgronnnn');
    // if (message.notification != null) {
    //   _cubit?.add(NeatTipNotification(
    //       createdAt: DateTime.now().toIso8601String(),
    //       body: message.notification!.body ?? '',
    //       title: message.notification!.title ?? ''));
    // }
    _messageStream.add(message);

    // implement your actions here
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    _messageStream.add(message);
    if (_runOnMessage != null) {
      _runOnMessage!(message);
    }
    // implement your actions here, if you want to use flutter_local_notifications, use the display() method.
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    log('heuheueh');
    _messageStream.add(message);
    if (_runOpenedMessage != null) {
      _runOpenedMessage!(message);
    }
    // _messageStream.close();
    // final data = await _messageStream.stream.toList();
    // log('data $data');
    // implement your actions here
  }

  static Future setRunOpenedMessage(Function onMessage) async {
    _runOpenedMessage = onMessage;
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
    // _messageStream.add(message);
    // _messageStream.close();
    // final data = await _messageStream.stream.toList();
    // log('data $data');
    // implement your actions here
  }

  static Future setRunOnMessage(Function onMessage) async {
    _runOnMessage = onMessage;
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    // _messageStream.add(message);
    // _messageStream.close();
    // final data = await _messageStream.stream.toList();
    // log('data $data');
    // implement your actions here
  }

  static Future initialize() async {
    // log('cubit $cubit');
    // _cubit = cubit;
    //Push notifications
    // await Firebase.initializeApp();

    idPush = await reloadFcmToken();
    log('idPush: $idPush');

    //Handler
    // FirebaseMessaging.instance.
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    // FirebaseMessaging.onMessage.listen(_onMessageHandler);

    // _messageStream.stream
    //local notifications initialization
    const InitializationSettings initializationSettings =
        InitializationSettings(
      // iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings("mipmap/ic_launcher"),
    );
    notificationPlugin.initialize(initializationSettings);
  }

  // mètode per obrir una notificació local (només amb l'app oberta)
  static void display(RemoteMessage message) async {
    try {
      AndroidNotification? android = message.notification?.android;
      await notificationPlugin.show(
          message.notification!.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: android?.smallIcon ?? "mipmap/ic_launcher",
              // channelAction: AndroidNotificationChannelAction.createIfNotExists
              // other properties...
            ),
          ));
    } on Exception catch (e) {
      log('e $e');
    }
  }

  // demanar permisos
  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
    }
  }

  static Future<String?> reloadFcmToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    // await sharedPreferences.remove("fcmToken");
    final sharePrefFcm = sharedPreferences.getString("fcmToken");
    // Map<String, dynamic>? fcmToken = jsonDecode(sharePrefFcm );
    final String? token = await messaging.getToken();
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

  static closeStreams() {
    _messageStream.close();
  }
}

// Future<FlutterLocalNotificationsPlugin> initializeFCM(
//     {NotificationListCubit? cubit}) async {
//   // FirebaseMessaging messaging = FirebaseMessaging.instance;
//   // log('message ${await messaging.getToken()}');
//   // String? fcmToken = await _getFcmToken();
//   log('siniii');
//   await reloadFcmToken();
//   // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   // log("Handling a background message: ${message.messageId}");
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('mipmap/ic_launcher');
// // final DarwinInitializationSettings initializationSettingsDarwin =
// //     DarwinInitializationSettings(
// //         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
// // final LinuxInitializationSettings initializationSettingsLinux =
// //     LinuxInitializationSettings(
// //         defaultActionName: 'Open notification');
//   const InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   return flutterLocalNotificationsPlugin;
// }

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   log('bekgron ${message.toMap()}');
//   RemoteNotification? notification = message.notification;
//   // cubit.add(NeatTipNotification(
//   //     createdAt: DateTime.now().toIso8601String(),
//   //     title: notification?.title ?? '',
//   //     body: notification?.body ?? ''));
//   // if (notification != null && mounted) {
//   //   context.read<NotificationListCubit>().add(NeatTipNotification(
//   //       createdAt: DateTime.now().toIso8601String(),
//   //       title: notification.title ?? '',
//   //       body: notification.body ?? ''));
//   // }

//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   // await Firebase.initializeApp();

//   // RemoteNotification? notification = message.notification;
//   // AndroidNotification? android = message.notification?.android;
//   // if (notification != null && android != null) {
//   //   flutterLocalNotificationsPlugin.show(
//   //       notification.hashCode,
//   //       notification.title,
//   //       notification.body,
//   //       NotificationDetails(
//   //         android: AndroidNotificationDetails(
//   //           channel.id,
//   //           channel.name,
//   //           channel.description,
//   //           icon: android.smallIcon,
//   //           // channelAction: AndroidNotificationChannelAction.createIfNotExists
//   //           // other properties...
//   //         ),
//   //       ));
//   // }

//   // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   //   log('messageww ${message.notification!.body}');

//   //   //   // If `onMessage` is triggered with a notification, construct our own
//   //   //   // local notification to show to users using the created channel.
//   //   //   if (notification != null && android != null) {
//   //   //     log('notification.hashCode ${notification.hashCode}');
//   //   //   }
//   // });
// }


