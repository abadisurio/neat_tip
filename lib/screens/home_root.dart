import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/bloc/notification_list.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/neattip_notification.dart';
import 'package:neat_tip/screens/customer/explore_spot.dart';
import 'package:neat_tip/screens/customer/home_customer.dart';
import 'package:neat_tip/screens/host/home_host.dart';
import 'package:neat_tip/screens/manage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/screens/notifications.dart';
import 'package:neat_tip/screens/reservation_detail.dart';
import 'package:neat_tip/screens/reservation_list.dart';
import 'package:neat_tip/service/fb_cloud_messaging.dart';
import 'package:neat_tip/widgets/snacbar_notification.dart';

class HomeRoot extends StatefulWidget {
  const HomeRoot({Key? key}) : super(key: key);

  @override
  State<HomeRoot> createState() => _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> {
  int _selectedIndex = 0;
  String userRole = 'Pengguna';
  static const thinStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w300);
  // static const TextStyle optionStyle = TextStyle(fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    const HomeCustomer(),
    const ExploreSpot(),
    const SizedBox(),
    const Notifications(),
    const Manage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _onScanTapped();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onScanTapped() {
    if (userRole == 'Pengguna') {
      Navigator.pushNamed(context, '/scan_vehicle_customer');
    } else {
      Navigator.pushNamed(context, '/scan_vehicle');
    }
  }

  @override
  void initState() {
    // PushNotificationService.onMessageOpenedHandler()
    //  FirebaseMessaging.onMessageOpenedApp.listen();
    // log('userRole ${context.read<NeatTipUserCubit>().state?.role}');
    userRole = context.read<NeatTipUserCubit>().state?.role ?? 'Pengguna';
    // log('userRole $userRole');
    if (userRole != 'Pengguna') {
      _widgetOptions[0] = const HomeHost();
      _widgetOptions[1] = const ReservationList();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushNotificationService.setRunOpenedMessage((RemoteMessage message) {
        if (message.data['reservationId'] != null) {
          Navigator.pushNamed(context, '/reservation_detail',
              arguments: ReservationArgument(
                  reservationId: message.data['reservationId']));
        }
      });
      PushNotificationService.setRunOnMessage((RemoteMessage message) {
        if (message.data['reservationId'] != null) {
          log('di home inii');
          RemoteNotification? notification = message.notification;
          if (notification != null && mounted) {
            log('sinikwaokwoa ${message.data}');
            // log('notification.hashCode ${notification.hashCode}');
            ScaffoldMessenger.of(context).showSnackBar(SnacbarNotification(
              icon: const Icon(Icons.motorcycle),
              content: ListTile(
                onTap: () {
                  if (message.data['reservationId'] != null) {
                    Navigator.pushNamed(context, '/reservation_detail',
                        arguments: ReservationArgument(
                            reservationId: message.data['reservationId']));
                  }
                },
                // dense: true,
                leading: const CircleAvatar(child: Icon(Icons.notifications)),
                title: Text(notification.title ?? ''),
                subtitle: Text(notification.body ?? ''),
                // trailing:
              ),
            ).create() // SnackBar(
                );
            context.read<NotificationListCubit>().add(NeatTipNotification(
                createdAt: DateTime.now().toIso8601String(),
                title: notification.title ?? '',
                body: notification.body ?? ''));
          }
        }
      });
    });
    // PushNotificationService.messagesStream.listen((RemoteMessage message) {
    // log('di home inii');
    // RemoteNotification? notification = message.notification;
    // if (notification != null && mounted) {
    //   log('sinikwaokwoa ${notification.toMap()}');
    //   // log('notification.hashCode ${notification.hashCode}');
    //   ScaffoldMessenger.of(context).showSnackBar(SnacbarNotification(
    //     icon: const Icon(Icons.motorcycle),
    //     content: ListTile(
    //       onTap: () {},
    //       // dense: true,
    //       leading: const CircleAvatar(child: Icon(Icons.notifications)),
    //       title: Text(notification.title ?? ''),
    //       subtitle: Text(notification.body ?? ''),
    //       // trailing:
    //     ),
    //   ).create() // SnackBar(
    //       );
    //   context.read<NotificationListCubit>().add(NeatTipNotification(
    //       createdAt: DateTime.now().toIso8601String(),
    //       title: notification.title ?? '',
    //       body: notification.body ?? ''));
    // }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<VehicleListCubit>().end();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            [
              'Neat Tip',
              userRole != 'Pengguna' ? 'Titipan' : 'Spots',
              'Pindai',
              'Kotak Masuk',
              'Pengaturan'
            ][_selectedIndex],
            style: thinStyle,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipOval(
                clipBehavior: Clip.hardEdge,
                child: GestureDetector(
                  onTap: () {
                    log('tapp');
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      height: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: FirebaseAuth.instance.currentUser?.photoURL ??
                          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=240',
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        // floatingActionButton: FloatingActionButton(
        //   // shape: FloatingActionButtonSh,
        //   onPressed: _onScanTapped,
        //   child: const Icon(Icons.fit_screen_outlined),
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: const CircularNotchedRectangle(),
            child: BottomNavigationBar(
              enableFeedback: false,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                      (userRole != 'Pengguna') ? Icons.motorcycle : Icons.map),
                  label: (userRole != 'Pengguna') ? 'Titipan' : 'Spots',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code),
                  label: 'Check-out',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  label: 'Inbox',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  label: 'Atur',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedFontSize: 12,
              unselectedItemColor: Colors.grey[700],
              selectedItemColor: Colors.blue[500],
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
