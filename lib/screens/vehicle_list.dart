import 'package:flutter/material.dart';

class VehicleList extends StatefulWidget {
  const VehicleList({super.key});

  @override
  State<VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleList> {
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan Anda'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                  onPressed: () {
                    navigator.pushNamed('/vehicleadd');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text('Tambah'),
                    ],
                  )
                  // child: Text('${item['name']}')
                  ),
            ),
          )
        ],
      ),
      body: SafeArea(
          child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return const VehicleItem();
        },
        // children: [],
      )),
    );
  }
}

class VehicleItem extends StatelessWidget {
  const VehicleItem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          print('hehe');
        },
        child: ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              height: 110,
                              width: 110,
                            ),
                            // Image.network(
                            //     "https://ik.imagekit.io/zlt25mb52fx/ahmcdn/uploads/product/feature/fa-clickable-feature-motor-700x700pxl-ys-1-26092022-061617.jpg"),
                            Image.asset(
                              'assets/vario.png',
                              height: 150,
                              width: 150,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'Jono • Honda Vario',
                          // style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Text(
                              'B 1234 ABC',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade100),
                            )),
                        const Text('4 wheel'),
                      ],
                    ),
                    // trailing: IconButton,
                  ),
                )
              ],
            ),
          ),
        )
        // child: ListTile(
        //   leading: SizedBox(
        //     height: 300,
        //     width: 100,
        //     child: ClipRRect(
        //       child: Image.network(
        //         "https://ik.imagekit.io/zlt25mb52fx/ahmcdn/uploads/product/feature/fa-clickable-feature-motor-700x700pxl-ys-1-26092022-061617.jpg",
        //         height: 300,
        //       ),
        //     ),
        //   ),
        //   title: Container(
        //       margin: const EdgeInsets.symmetric(vertical: 4.0),
        //       padding: const EdgeInsets.all(8.0),
        //       decoration: BoxDecoration(
        //           color: Colors.grey.shade900,
        //           borderRadius: BorderRadius.circular(8.0)),
        //       child: Text(
        //         'B 1234 ABC',
        //         style: TextStyle(
        //             fontWeight: FontWeight.bold, color: Colors.grey.shade100),
        //       )),
        //   subtitle: const Text('Honda Vario'),
        // )
        );
  }
}
