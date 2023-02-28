import 'package:flutter/material.dart';

class VehicleAllow extends StatefulWidget {
  final String plateNumber;
  const VehicleAllow({Key? key, required this.plateNumber}) : super(key: key);

  @override
  State<VehicleAllow> createState() => _VehicleAllowState();
}

class _VehicleAllowState extends State<VehicleAllow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izin Kendaraan')),
      body: Center(child: Text('text ${widget.plateNumber}')),
    );
  }
}
