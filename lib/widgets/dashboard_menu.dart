import 'package:flutter/material.dart';

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({super.key});

  static const List<Map<String, dynamic>> menuList = [
    {"name": "Spots", "route": "/spots", "icon": Icons.explore_outlined},
    {"name": "Reservasi", "route": "/reservations", "icon": Icons.menu_book},
    {"name": "Wallet", "route": "/wallet", "icon": Icons.wallet},
    {"name": "Kendaraan", "route": "/vehiclelist", "icon": Icons.motorcycle},
    // {"name": "Pro", "route": "/spots", "icon": Icons.explore_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).highlightColor,
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: menuList.map((item) {
            // log('${item['name']}');
            return IntrinsicHeight(
              child: Column(
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        await navigator.pushNamed(item['route']);
                      },
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            );
          }).toList()),
    );
  }
}
