import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';

class VehicleRequest extends StatefulWidget {
  const VehicleRequest({super.key});

  @override
  State<VehicleRequest> createState() => _VehicleRequestState();
}

class _VehicleRequestState extends State<VehicleRequest> {
  String _plateNumber = '';
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    // controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 1),
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) => _getArgument());
    // animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  _getArgument() async {
    final argument =
        ModalRoute.of(context)!.settings.arguments as String? ?? '';
    setState(() {
      _plateNumber = argument;
    });
  }

  _requestPairing() async {
    final vehicleListCubit = context.read<VehicleListCubit>();
    setState(() {
      _isRequesting = true;
    });
    // await Future.delayed(const Duration(milliseconds: 1000));
    await vehicleListCubit.addUserVehicles(_plateNumber);
    setState(() {
      _isRequesting = false;
    });
    // addDataToDB
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_plateNumber),
          const Text(
              'Kendaraan sudah ada. Minta pemilik untuk hubungkan dengan akun Anda'),
          if (_isRequesting)
            const CircularProgressIndicator()
          else
            ElevatedButton(
                onPressed: _requestPairing,
                child: const Text('Minta Hubungkan'))
        ],
      ),
    );
  }
}
