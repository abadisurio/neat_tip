import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/screens/home.dart';
import 'package:neat_tip/screens/manage.dart';

class HomeRoot extends StatefulWidget {
  const HomeRoot({Key? key}) : super(key: key);

  @override
  State<HomeRoot> createState() => _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    Text(
      'Sosial',
      style: optionStyle,
    ),
    SizedBox(),
    Text(
      'Notifikasi',
      style: optionStyle,
    ),
    Manage(),
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
    Navigator.pushNamed(context, '/wallet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text([
          'Neat Tip',
          'Sosial',
          'Pindai',
          'Notifikasi',
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
      floatingActionButton: FloatingActionButton(
        // shape: FloatingActionButtonSh,
        onPressed: _onScanTapped,
        child: const Icon(Icons.fit_screen_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
          enableFeedback: false,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.public_outlined),
              label: 'Sosial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.remove),
              label: 'Pindai',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notif',
            ),
            BottomNavigationBarItem(
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
    );
  }
}
