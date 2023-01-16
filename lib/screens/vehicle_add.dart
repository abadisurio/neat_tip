import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class VehicleAdd extends StatefulWidget {
  const VehicleAdd({super.key});

  @override
  State<VehicleAdd> createState() => VehicleAddState();
}

class VehicleAddState extends State<VehicleAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kendaraan'),
      ),
      body: SafeArea(
          child: Center(
        child: const Text('add vehicle'),
      )),
    );
  }
}
