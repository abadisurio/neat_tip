import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/widgets/vehicle_item.dart';
import 'package:skeletons/skeletons.dart';

class ReservationArgument {
  bool? newlySucceded;
  late String reservationId;
  ReservationArgument({this.newlySucceded, required this.reservationId});
}

const List<Map<String, dynamic>> prices = [
  {'name': 'Biaya Penitipan Perhari', 'price': 5000},
  {'name': 'Potongan', 'price': -3000},
];

class ReservationDetail extends StatefulWidget {
  const ReservationDetail({Key? key}) : super(key: key);

  @override
  State<ReservationDetail> createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  late ReservationArgument? _reservationArgument;
  late Reservation? _reservation;
  late ReservationsListCubit _reservationsListCubit;
  late VehicleListCubit _vehicleListCubit;
  Vehicle? _vehicle;
  int _animationStep = 0;
  int _reservationStep = 1;

  @override
  void initState() {
    super.initState();
    _vehicleListCubit = context.read<VehicleListCubit>();
    _reservationsListCubit = context.read<ReservationsListCubit>();
    _vehicle = _vehicleListCubit.state.first;
    _startAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getDetail());
  }

  _startAnimation() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _reservationStep = 2;
        _animationStep += 1;
      });
      // if (mounted) {}
    });
  }

  _getDetail() async {
    // await argument();
    // log('_reservationArgument ${_reservationArgument!.reservationId}');
    if (_reservationArgument == null) return;
    log('_reservationArgument ${_reservationArgument!.reservationId}');
    final reservation =
        _reservationsListCubit.findById(_reservationArgument!.reservationId);
    log('reservationdsda ${reservation!.id}');
  }

  @override
  Widget build(BuildContext context) {
    log('_reservationStep $_reservationStep');
    _reservationArgument =
        ModalRoute.of(context)!.settings.arguments as ReservationArgument?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          Text(
            'Selesai',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penitipan',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Text(
                    'Kurnia Motor',
                  ),
                ],
              ),
              TextButton(
                child: const Text('Lihat Tempat'),
                onPressed: () => Navigator.pushNamed(context, '/spot_detail'),
              )
            ],
          ),
          const Divider(),
          () {
            if (_vehicle == null) {
              return SizedBox(
                height: 120,
                child: Center(
                  child: SkeletonListView(
                    itemCount: 1,
                  ),
                ),
              );
            } else {
              return VehicleItem(vehicle: _vehicle!);
            }
          }(),
          Center(
            child: SizedBox(
              width: 250,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedAlign(
                    alignment: _reservationStep == 0
                        ? Alignment.centerLeft
                        : _reservationStep == 1
                            ? Alignment.center
                            : Alignment.centerRight,
                    curve: Curves.easeOutExpo,
                    duration: const Duration(milliseconds: 700),
                    child: CircularProgressIndicator(
                      value: _animationStep >= 1 ? 1 : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.home_filled),
                        Icon(Icons.linear_scale),
                        Icon(Icons.motorcycle),
                        Icon(Icons.linear_scale),
                        Icon(Icons.person)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Sudah dikembalikan\n',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-in',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    DateFormat('EEE, dd MMM yyyy', 'id_ID')
                        .format(DateTime.now()),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Durasi',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Text(
                    '2 Hari',
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Check-out',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    DateFormat('EEE, dd MMM yyyy', 'id_ID')
                        .format(DateTime.now()),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Text(
            'Rincian Pembayaran',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          ...prices.map(
            (e) {
              final isSurplus = (e['price'] as int) < 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e['name']),
                  Text(
                    '${isSurplus ? '-' : ''}Rp${(e['price'] as int).abs()}',
                    style: TextStyle(
                        color: (isSurplus ? Colors.green.shade700 : null)),
                  )
                ],
              );
            },
          ).toList(),
          Row(
            children: [
              Expanded(
                  child: Text(
                'Jumlah',
                style: Theme.of(context).textTheme.titleSmall,
              )),
              Text(
                'Rp${(prices.fold(0, (previousValue, element) => previousValue + ((element['price'] as int) > 0 ? (element['price'] as int) : 0)))} ',
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough, color: Colors.grey),
              ),
              Text(
                  'Rp${(prices.fold(0, (previousValue, element) => previousValue + (element['price'] as int)))}')
            ],
          ),
          const Divider(),
          Text(
            'Pembayaran',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Row(
            children: [
              const Expanded(child: Text('Saldo Neat Tip')),
              Text(
                  'Rp${(prices.fold(0, (previousValue, element) => previousValue + (element['price'] as int)))}')
            ],
          ),
          const Divider(),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.flag_circle),
                onPressed: () {},
              ),
              Expanded(
                child: ElevatedButton(
                    onPressed: () {}, child: const Text('Beri Ulasan')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
