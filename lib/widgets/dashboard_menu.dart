import 'package:flutter/material.dart';

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({super.key});

  static const List<Map<String, dynamic>> menuList = [
    // {"name": "Spots", "route": "/spots", "icon": Icons.explore_outlined},
    {"name": "Reservasi", "route": "/reservations", "icon": Icons.menu_book},
    {"name": "Kendaraan", "route": "/vehiclelist", "icon": Icons.motorcycle},
    {
      "name": "Simulasi Check-in",
      "route": "/scan_vehicle",
      "icon": Icons.input_rounded
    },
    // {"name": "Pro", "route": "/spots", "icon": Icons.explore_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return GridView.count(
      childAspectRatio: 2.5,
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      crossAxisCount: 2,
      children: menuList.map((item) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ElevatedButton(
            style: const ButtonStyle(
                padding: MaterialStatePropertyAll(EdgeInsets.zero)),
            onPressed: () {
              navigator.pushNamed(item['route']);
            },
            child: Stack(alignment: Alignment.center, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: const Offset(-20, -10),
                  child: Icon(
                    item['icon'],
                    color: Colors.white12,
                    size: 120,
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(item["name"]),
                  ))
            ]),
          ),
        );
        // log('${item['name']}');
        // return IntrinsicHeight(
        //   child: Column(
        //     children: [
        //       ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             padding: const EdgeInsets.symmetric(vertical: 18),
        //             backgroundColor: Theme.of(context).primaryColor,
        //             elevation: 0,
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(8.0),
        //             ),
        //           ),
        //           onPressed: () async {
        //             await navigator.pushNamed(item['route']);
        //           },
        //           child: Icon(
        //             item['icon'],
        //             color: Colors.grey.shade200,
        //           )
        //           // child: Text('${item['name']}')
        //           ),
        //       const SizedBox(
        //         height: 10,
        //       ),
        //       Text(
        //         item['name'],
        //         style: const TextStyle(fontWeight: FontWeight.bold),
        //       )
        //     ],
        //   ),
        // );
      }).toList(),
    );
  }
}
