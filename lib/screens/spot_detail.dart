import 'package:flutter/material.dart';

class SpotDetail extends StatefulWidget {
  const SpotDetail({Key? key}) : super(key: key);

  @override
  State<SpotDetail> createState() => _SpotDetailState();
}

class _SpotDetailState extends State<SpotDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Tempat Penitipan'),
      ),
    );
  }
}
