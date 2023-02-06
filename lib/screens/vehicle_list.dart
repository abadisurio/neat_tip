// ignore_for_file: avoid_print
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/widgets/peek_and_pop_able.dart';

class VehicleList extends StatelessWidget {
  const VehicleList({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    removeItem(Vehicle vehicle) async {
      await Navigator.maybePop(context);
      Future.delayed(peekDuration, () async {
        await Navigator.pushNamed(context, '/loading', arguments: () async {
          await context.read<VehicleListCubit>().removeVehicle(vehicle);
          // await vehicleListCubit.add();
          log('hereeeeee');
        });
      });
    }

    return BlocBuilder<VehicleListCubit, List<Vehicle>>(
        builder: (context, vehicleList) {
      log('rerender ${vehicleList.length}');
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
                itemCount: vehicleList.length,
                itemBuilder: (context, index) {
                  return PeekAndPopable(
                      // removeByIndex
                      actions: [
                        {
                          "name": "Hapus",
                          "icon": Icons.delete,
                          "color": Colors.red,
                          "onTap": () => removeItem(vehicleList[index])
                        },
                        // {
                        //   "name": "Ubah",
                        //   "icon": Icons.edit,
                        //   "color": Colors.white,
                        //   "onTap": () {}
                        // },
                      ],
                      peekPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 300),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: VehicleItem(
                          vehicle: vehicleList[index],
                        ),
                      ));
                },
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
    final firstPath = vehicle.imgSrcPhotos.split(',').first;
    final File cover = File(firstPath);

    return Padding(
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
              subtitle: Text(
                '${vehicle.wheel} wheel',
                maxLines: 1,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Container(
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
            ),
          )
        ],
      ),
    );
  }
}
