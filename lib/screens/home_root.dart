import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/screens/customer/explore_spot.dart';
import 'package:neat_tip/screens/customer/home_customer.dart';
import 'package:neat_tip/screens/host/home_host.dart';
import 'package:neat_tip/screens/manage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/screens/customer/vehicle_list.dart';
import 'package:neat_tip/widgets/snacbar_notification.dart';

class HomeRoot extends StatefulWidget {
  const HomeRoot({Key? key}) : super(key: key);

  @override
  State<HomeRoot> createState() => _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> {
  int _selectedIndex = 0;
  String userRole = 'Pengguna';
  static const TextStyle optionStyle = TextStyle(fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    const HomeCustomer(),
    const ExploreSpot(),
    const SizedBox(),
    const Text(
      'Kotak Masuk',
      style: optionStyle,
    ),
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
    ScaffoldMessenger.of(context).showSnackBar(SnacbarNotification(
      icon: const Icon(Icons.motorcycle),
      content: ListTile(
        onTap: () {},
        // dense: true,
        leading: const Icon(Icons.motorcycle),
        title: const Text('Kurnia Motor'),
        subtitle: const Text('Dititipkan • Hari ini'),
        // trailing:
      ),
    ).create() // SnackBar(
        );
  }

  @override
  void initState() {
    log('userRole ${context.read<NeatTipUserCubit>().state?.role}');
    userRole = context.read<NeatTipUserCubit>().state?.role ?? 'Pengguna';
    log('userRole $userRole');
    if (userRole != 'Pengguna') {
      _widgetOptions[0] = const HomeHost();
      _widgetOptions[1] = const VehicleList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text([
          'Neat Tip',
          userRole != 'Pengguna' ? 'Titipan' : 'Spots',
          'Pindai',
          'Kotak Masuk',
          'Pengaturan'
        ][_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipOval(
              clipBehavior: Clip.hardEdge,
              child: GestureDetector(
                onTap: () {
                  log('tapp');
                },
                child: Image.network(
                  FirebaseAuth.instance.currentUser?.photoURL ??
                      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=240',
                  fit: BoxFit.cover,
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
                icon: Icon(Icons.remove),
                label: 'Pindai',
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
    );
  }
}
