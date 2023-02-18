import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialogFindPlate extends StatefulWidget {
  const DialogFindPlate({Key? key}) : super(key: key);

  @override
  State<DialogFindPlate> createState() => _DialogFindPlateState();
}

class _DialogFindPlateState extends State<DialogFindPlate> {
  TextEditingController plateController = TextEditingController();
  String _plate = '';
  bool _isPlateExists = false;
  bool isChecking = false;
  _onPlateChange(String? plate) {
    // log('plate $plate');
    if (plate != null && regexPlate.hasMatch(plate)) {
      setState(() {
        _plate = plate;
      });
    }
  }

  _submitPlate() async {
    await Navigator.pushNamed(context, '/state_loading', arguments: () async {
      final isPlateExists =
          await context.read<VehicleListCubit>().checkIsPlateExists(_plate);
      setState(() {
        _isPlateExists = isPlateExists;
      });
      // await Future.delayed(const Duration(milliseconds: 1000));
    });
    if (mounted && !_isPlateExists) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/vehicleadd', arguments: _plate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('_plate $_plate');
    log('_isPlateExists $_isPlateExists');
    return AlertDialog(
      title: const Text('Tambah Kendaraan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Silakan isi nomor plat kendaraan\n'),
          TextFormField(
            onChanged: _onPlateChange,
            autofocus: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan plat nomor',
                labelText: 'Plat nomor'),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: _plate == '' ? null : _submitPlate,
          child: const Text('Lanjutkan'),
        ),
      ],
    );
  }
}
