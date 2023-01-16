import 'dart:developer';

import 'package:flutter/material.dart';

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({super.key});

  static const List<Map<String, dynamic>> menuList = [
    {"name": "Spots", "route": "/spots", "icon": Icons.explore_outlined},
    {"name": "History", "route": "/history", "icon": Icons.list_alt_outlined},
    {"name": "Ewallet", "route": "/ewallet", "icon": Icons.wallet},
    // {"name": "Pro", "route": "/spots", "icon": Icons.explore_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: menuList.map((item) {
            log('${item['name']}');
            return IntrinsicHeight(
              child: Column(
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.grey.shade800,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {},
                      child: Icon(
                        item['icon'],
                        color: Colors.grey.shade200,
                      )
                      // child: Text('${item['name']}')
                      ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    item['name'],
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          }).toList()),
    );
  }
}
