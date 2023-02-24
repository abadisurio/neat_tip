import 'dart:developer';

import 'package:flutter/material.dart';

class ReservationDetail extends StatefulWidget {
  const ReservationDetail({Key? key}) : super(key: key);

  @override
  State<ReservationDetail> createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  late String? _argument;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getDetail());
  }

  _getDetail() async {
    // await argument();
    log('_argument $_argument');
  }

  @override
  Widget build(BuildContext context) {
    _argument = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Reservasi'),
      ),
    );
  }
}
