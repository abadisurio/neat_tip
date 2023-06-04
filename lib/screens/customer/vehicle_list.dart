import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/screens/dialog_find_plate.dart';
import 'package:neat_tip/widgets/peek_and_pop_able.dart';
import 'package:neat_tip/widgets/vehicle_item.dart';

class VehicleList extends StatefulWidget {
  const VehicleList({super.key});

  @override
  State<VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleList> {
  late VehicleListCubit _vehicleListCubit;

  _reloadData() async {
    // _vehicleListCubit
    await _vehicleListCubit.reload();
  }

  @override
  void initState() {
    _vehicleListCubit = context.read<VehicleListCubit>();
    _reloadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final navigator = Navigator.of(context);
    checkPlate() async {
      if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return const DialogFindPlate();
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Hubungkan internet terlebih dahulu!')));
      }
    }

    removeItem(Vehicle vehicle) async {
      await Navigator.maybePop(context);
      Future.delayed(peekDuration, () async {
        await Navigator.pushNamed(context, '/state_loading',
            arguments: () async {
          try {
            await context.read<VehicleListCubit>().removeVehicle(vehicle);
            // await vehicleListCubit.add();
            log('hereeeeee');
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Gagal: $e')));
          }
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
                      onPressed: checkPlate,
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
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<VehicleListCubit>().reload();
            },
            child: SafeArea(child: () {
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
            }()),
          ));
    });
  }
}
