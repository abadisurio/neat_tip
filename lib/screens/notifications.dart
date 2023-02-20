// import 'dart:developer';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:neat_tip/utils/constants.dart';

// class Notifications extends StatefulWidget {
//   const Notifications({Key? key}) : super(key: key);

//   @override
//   State<Notifications> createState() => _NotificationsState();
// }

// class _NotificationsState extends State<Notifications> {
//   late final FirebaseMessaging _messaging;
//   void registerNotification() async {
//     // 1. Initialize the Firebase app
//     // await Firebase.initializeApp();

//     // 2. Instantiate Firebase Messaging
//     _messaging = FirebaseMessaging.instance;

//     // 3. On iOS, this helps to take the user permissions
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');

// // For handling the received notifications
//       // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       //   log('messageee $message');
//       //   // Parse the message received
//       //   // PushNotification notification = PushNotification(
//       //   //   title: message.notification?.title,
//       //   //   body: message.notification?.body,
//       //   // );

//       //   // setState(() {
//       //   //   _notificationInfo = notification;
//       //   //   _totalNotifications++;
//       //   // });
//       // });
//     } else {
//       print('User declined or has not accepted permission');
//     }
//   }

//   Future<void> setupInteractedMessage() async {
//     // Get any messages which caused the application to open from
//     // a terminated state.
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();

//     // If the message also contains a data property with a "type" of "chat",
//     // navigate to a chat screen
//     if (initialMessage != null) {
//       _handleMessage(initialMessage);
//     }

//     // Also handle any interaction when the app is in the background via a
//     // Stream listener
//     // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
//   }

//   void _handleMessage(RemoteMessage message) {
//     if (message.data['type'] == 'chat') {
//       // Navigator.pushNamed(context, '/chat',
//       //   arguments: ChatArguments(message),
//       // );
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;

//       // If `onMessage` is triggered with a notification, construct our own
//       // local notification to show to users using the created channel.
//       if (notification != null && android != null) {
//         FlutterLocalNotificationsPlugin().show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 channel.id,
//                 channel.name,
//                 channel.description,
//                 icon: android.smallIcon,
//                 // other properties...
//               ),
//             ));
//       }
//     });
//     // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     //   print('Got a message whilst in the foreground!');
//     //   // print('Message data: ${message.data}');
//     //   print('Message data: ${message.notification!.body}');

//     //   if (message.notification != null) {
//     //     print('Message also contained a notification: ${message.notification}');
//     //   }
//     // });
//     // Run code required to handle interacted messages in an async function
//     // as initState() must not be async
//     setupInteractedMessage();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text("...");
//   }
// }
