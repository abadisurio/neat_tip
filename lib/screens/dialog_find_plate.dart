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
  final _formKey = GlobalKey<FormState>();
  TextEditingController plateController = TextEditingController();
  String _plate = '';
  late VehicleListCubit _vehicleListCubit;
  bool _isPlateAdded = false;
  bool _isPlateExists = false;
  bool isChecking = false;

  _onPlateChange(String? plate) async {
    // log('plate $plate');
    if (plate != null && regexPlate.hasMatch(plate)) {
      // setState(() {
      // });
      setState(() {
        _isPlateAdded = false;
        _plate = plate;
      });
      if (_vehicleListCubit.checkIsPlateAdded(_plate)) {
        log('sini');
        setState(() {
          _isPlateAdded = true;
        });
        // return;
      }
    }
    log('_isPlateAdded $_isPlateAdded');
  }

  _submitPlate() async {
    log('_isPlateAdded $_isPlateAdded');
    if (_formKey.currentState!.validate()) {
      await Navigator.pushNamed(context, '/state_loading', arguments: () async {
        final isPlateExists =
            await _vehicleListCubit.checkIsPlateExists(_plate);
        setState(() {
          _isPlateExists = isPlateExists;
        });
        // await Future.delayed(const Duration(milliseconds: 1000));
      });
      if (mounted) {
        Navigator.pop(context);
      }
      if (mounted && !_isPlateExists) {
        Navigator.pushNamed(context, '/vehicle_add', arguments: _plate);
      } else {
        Navigator.pushNamed(context, '/vehicle_request', arguments: _plate);
      }
    }
  }

  @override
  void initState() {
    _vehicleListCubit = context.read<VehicleListCubit>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // log('_plate $_plate');
    // log('_isPlateAdded $_isPlateAdded');
    return AlertDialog(
      title: const Text('Tambah Kendaraan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Silakan isi nomor plat kendaraan\n'),
          Form(
            key: _formKey,
            child: TextFormField(
              validator: (value) {
                log('value $value');
                if (value == null || _isPlateAdded) {
                  return 'Kendaraan sudah ditambahkan!';
                }
                return null;
              },
              onChanged: _onPlateChange,
              autofocus: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan plat nomor',
                  labelText: 'Plat nomor'),
            ),
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
