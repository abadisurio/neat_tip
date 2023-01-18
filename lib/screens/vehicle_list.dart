import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/vehicle.dart';

class VehicleList extends StatefulWidget {
  const VehicleList({super.key});

  @override
  State<VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleList> {
  late VehicleListCubit mBloc;
  late StreamSubscription mSub;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return BlocBuilder<VehicleListCubit, List<Vehicle>>(
        // listener: (context, vehicleList) {
        //   log('vehicleList $vehicleList');
        //   setState(() {
        //     _vehicleList = vehicleList;
        //   });
        // },
        builder: (context, vehicleList) {
      log('vehicleList $vehicleList');
      // setState(() {
      //   vehicleList = vehicleList;
      // });

      return Scaffold(
          appBar: AppBar(
            title: const Text('Kendaraan Anda'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ElevatedButton(
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
          body: SafeArea(child: () {
            // if (vehicleList == null) {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // } else
            if (vehicleList.isEmpty) {
              return const Center(
                child: Text(
                    'Kamu belum menambahkan kendaraanmu.\nTambahkan sekarang, yuk!'),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vehicleList.length,
                itemBuilder: (context, index) {
                  return VehicleItem(
                    vehicle: vehicleList[index],
                  );
                },
                // children: [],
              );
            }
          }()));
    });
  }
}

class VehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleItem({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    // log('vehicle img ${vehicle.imgSrcPhotos}');
    final firstPath = vehicle.imgSrcPhotos.split(',').first;
    final File cover = File(firstPath);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        print('hehe');
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          height: 100,
                          width: 100,
                        ),
                        if (firstPath == '')
                          Image.network(
                              "https://ik.imagekit.io/zlt25mb52fx/ahmcdn/uploads/product/feature/fa-clickable-feature-motor-700x700pxl-ys-1-26092022-061617.jpg"),
                        // Image.asset(
                        //   'assets/vario.png',
                        //   height: 150,
                        //   width: 150,
                        // ),
                        if (firstPath != '')
                          Image.file(
                            cover,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListTile(
                isThreeLine: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Milik ${vehicle.ownerName}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
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
                          vehicle.plate,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade100),
                        )),
                    Text('${vehicle.wheel} wheel'),
                  ],
                ),
                // trailing: IconButton,
              ),
            )
          ],
        ),
      ),
    );
  }
}
