import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:neat_tip/bloc/app_state.dart';
import 'package:neat_tip/bloc/camera.dart';
import 'package:neat_tip/bloc/notification_list.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/bloc/transaction_list.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/neattip_user.dart';
import 'package:neat_tip/screens/home_root.dart';
import 'package:neat_tip/screens/introduction.dart';
import 'package:neat_tip/screens/loading_window.dart';
import 'package:neat_tip/screens/permission_window.dart';
import 'package:neat_tip/service/fb_cloud_messaging.dart';
import 'package:neat_tip/utils/route_generator.dart';
import 'package:neat_tip/utils/theme_data.dart';
import 'package:neat_tip/utils/theme_data_dark.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  await PushNotificationService.initialize();
  // PushNotificationService.messagesStream.listen((event) {
  //   log('wkwk');
  // });
  // await initializeFCM();
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   // RemoteNotification? notification = ;
  //   log('sinik ${message.data}');
  //   // if (notification != null) {
  //   //   log('notification.hashCode ${notification.hashCode}');
  //   //   ScaffoldMessenger.of(context).showSnackBar(SnacbarNotification(
  //   //     icon: const Icon(Icons.motorcycle),
  //   //     content: ListTile(
  //   //       onTap: () {},s
  //   //       // dense: true,
  //   //       leading: const Icon(Icons.notifications),
  //   //       title: Text(notification.title ?? ''),
  //   //       subtitle: Text(notification.body ?? ''),
  //   //       // trailing:
  //   //     ),
  //   //   ).create() // SnackBar(
  //   //       );
  //   // }
  // });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isNeedPermission = false;
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  late NeatTipUser? user;
  late List<CameraDescription> cameras;
  late NeatTipDatabase database;
  late VehicleListCubit vehicleListCubit;
  late AppStateCubit appStateCubit;
  late NotificationListCubit notificationListCubit;
  late TransactionsListCubit transactionsListCubit;
  late ReservationsListCubit reservationsListCubit;
  late NeatTipUserCubit neatTipUserCubit;
  late CameraCubit cameraCubit;
  late RouteObserverCubit routeObserverCubit;

  Future<void> initializeComponents() async {
    // log('panggil');
    await initializeDateFormatting('id_ID', null);
    await neatTipUserCubit.initialize();
    await appStateCubit.initialize();
    // await neatTipUserCubit.signOut();

    isNeedPermission = await checkPermission();
    user = neatTipUserCubit.state;
    database =
        await $FloorNeatTipDatabase.databaseBuilder('database.db').build();

    // await PushNotificationService.initialize(cubit: notificationListCubit);

    // vehicleListCubit.pullDataFromDB();

    transactionsListCubit.initializeDB(database);
    transactionsListCubit.pullDataFromDB();
    vehicleListCubit.initialize(localDB: database);
    notificationListCubit.initialize(localDB: database);
    reservationsListCubit.initialize(localDB: database);
    if (user != null) {
      reservationsListCubit.reload(role: user!.role);
      vehicleListCubit.reload();
      // notificationListCubit.reload();
    }
    // reservationsListCubit.pullDataFromDB();

    cameras = await availableCameras();
    cameraCubit.setCameraList(cameras);
    routeObserverCubit.setRouteObserver(routeObserver);
  }

  Future<bool> checkPermission() async {
    bool isAllAllowed = true;

    for (var service in serviceList) {
      final Permission permission = service['type'];
      final status = await permission.status;
      if (!status.isGranted) isAllAllowed = false;
    }
    return isAllAllowed;
  }

  @override
  void initState() {
    super.initState();

    vehicleListCubit = VehicleListCubit();
    neatTipUserCubit = NeatTipUserCubit();
    transactionsListCubit = TransactionsListCubit();
    appStateCubit = AppStateCubit();
    notificationListCubit = NotificationListCubit();
    reservationsListCubit = ReservationsListCubit();
    cameraCubit = CameraCubit();
    routeObserverCubit = RouteObserverCubit();
  }

  @override
  Widget build(BuildContext context) {
    // const roleType = UserRoleType.hostOwner;
    return FutureBuilder(
        future: initializeComponents(),
        builder: (context, snapshot) {
          return MultiBlocProvider(
              providers: [
                BlocProvider<AppStateCubit>(
                    create: (BuildContext context) => appStateCubit),
                BlocProvider<NotificationListCubit>(
                    create: (BuildContext context) => notificationListCubit),
                BlocProvider<CameraCubit>(
                    create: (BuildContext context) => cameraCubit),
                BlocProvider<RouteObserverCubit>(
                    create: (BuildContext context) => routeObserverCubit),
                BlocProvider<VehicleListCubit>(
                    create: (BuildContext context) => vehicleListCubit),
                BlocProvider<TransactionsListCubit>(
                    create: (BuildContext context) => transactionsListCubit),
                BlocProvider<ReservationsListCubit>(
                    create: (BuildContext context) => reservationsListCubit),
                BlocProvider<NeatTipUserCubit>(
                    create: (BuildContext context) => neatTipUserCubit),
              ],
              child: BlocBuilder<AppStateCubit, AppState>(
                builder: (context, appState) {
                  log('appState ${appState.darkMode}');
                  return
                      // snapshot.connectionState != ConnectionState.done
                      //     ? const SizedBox()
                      //     :
                      MaterialApp(
                    themeMode:
                        (appState.darkMode) ? ThemeMode.dark : ThemeMode.light,
                    title: 'Neat Tip',
                    navigatorObservers: [routeObserver],
                    debugShowCheckedModeBanner: false,
                    darkTheme: getThemeDataDark(),
                    theme: getThemeData(),
                    onGenerateRoute: routeGenerator,
                    home: () {
                      // FlutterNativeSplash.remove();
                      // return LoadingWindow();
                      log('snapshot.connectionState ${snapshot.connectionState}');
                      log('darkmode ${appState.darkMode}');
                      if (snapshot.connectionState != ConnectionState.done) {
                        //  FlutterNativeSplash.remove();
                        return const LoadingWindow();
                        // } else {
                      }
                      FlutterNativeSplash.remove();
                      if (user == null) {
                        return const Introduction();
                      } else if (!isNeedPermission) {
                        return Builder(builder: (context) {
                          return PermissionWindow(
                            onAllowedAll: () {
                              Navigator.pushNamedAndRemoveUntil(context, () {
                                switch (user!.role) {
                                  case 'host_owner':
                                    return '/homehost';
                                  default:
                                    return '/homeroot';
                                }
                              }(), (route) => false);
                            },
                          );
                        });
                      }
                      return const HomeRoot();
                    }(),
                  );
                },
              ));
        });
  }
}
