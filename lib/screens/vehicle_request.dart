import 'dart:developer';

import 'package:flutter/material.dart';

class VehicleRequest extends StatefulWidget {
  const VehicleRequest({super.key});

  @override
  State<VehicleRequest> createState() => _VehicleRequestState();
}

class _VehicleRequestState extends State<VehicleRequest> {
  String _plateNumber = '';

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

  _requestPairing() {
    log('pairing');
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
          ElevatedButton(
              onPressed: _requestPairing, child: const Text('Minta Hubungkan'))
        ],
      ),
    );
  }
}
