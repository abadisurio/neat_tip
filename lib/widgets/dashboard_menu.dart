import 'dart:developer';

import 'package:flutter/material.dart';

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({super.key});

  static const List<Map<String, dynamic>> menuList = [
    {"name": "Spots", "route": "/spots", "icon": Icons.explore_outlined},
    {"name": "History", "route": "/history", "icon": Icons.list_alt_outlined},
    {"name": "Ewallet", "route": "/ewallet", "icon": Icons.wallet},
    {"name": "Spots", "route": "/spots", "icon": Icons.explore_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: menuList.map((item) {
            log('${item['name']}');
            return Column(
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.grey.shade200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {},
                    child: Icon(
                      item['icon'],
                      color: Colors.grey.shade600,
                    )
                    // child: Text('${item['name']}')
                    ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  item['name'],
                  style: TextStyle(color: Colors.grey.shade600),
                )
              ],
            );
          }).toList()),
    );
  }
}
