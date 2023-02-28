import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/models/spot.dart';
import 'package:neat_tip/models/transactions.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/utils/date_time_count.dart';
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
  final ReservationArgument reservationArgument;
  const ReservationDetail({Key? key, required this.reservationArgument})
      : super(key: key);

  @override
  State<ReservationDetail> createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  late ReservationsListCubit _reservationsListCubit;
  late VehicleListCubit _vehicleListCubit;
  String? _status;
  Reservation? _reservation;
  Transactions? _transactions;
  Spot? _spot;
  Vehicle? _vehicle;
  int _animationStep = 0;
  int _reservationStep = 1;

  @override
  void initState() {
    super.initState();
    _vehicleListCubit = context.read<VehicleListCubit>();
    _reservationsListCubit = context.read<ReservationsListCubit>();
    // context.read<Spot>
    _startAnimation();
    _getDetail();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _getDetail());
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

  Future<void> _getDetail() async {
    // await Future.delayed(const Duration(milliseconds: 500));
    log('_reservationArgument ${widget.reservationArgument.reservationId}');
    final rsvpData = await _reservationsListCubit
        .findById(widget.reservationArgument.reservationId);
    setState(() {
      _reservation = rsvpData;
      _vehicle = _vehicleListCubit.findByPlate(_reservation!.plateNumber);
      _spot = Spot(id: 'id', name: 'Kurnia Motor');
      _transactions = Transactions(
          id: 'id',
          customerUserId: _reservation!.customerId ?? '',
          timeRequested: 'timeRequested');
      _status = _reservation!.status;
    });
    log('reservationdsda ${_reservation?.toJson()}');
    log('_vehicle ${_vehicle?.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservasi'),
      ),
      body: RefreshIndicator(
        onRefresh: _getDetail,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            SizedBox(
              height: 200,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_status == null)
                      const SkeletonLine()
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _status == 'ongoing'
                                ? 'Dalam titipan'
                                : _status == 'cancelled'
                                    ? 'Dibatalkan'
                                    : 'Selesai',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (_status == 'ongoing')
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow.shade800),
                                onPressed: () => Navigator.pushNamed(
                                    context, '/scan_vehicle_customer',
                                    arguments: _reservation?.id),
                                child: const Text('Check-out sekarang'))
                          else
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () {},
                                child: const Text('Lihat invoice'))
                        ],
                      ),
                    const Divider(),
                    () {
                      if (_vehicle == null) {
                        return SizedBox(
                          height: 130,
                          child: Center(
                            child: SkeletonListTile(),
                          ),
                        );
                      } else {
                        return VehicleItem(vehicle: _vehicle!);
                      }
                    }(),
                  ]),
            ),
            Center(
              child: SizedBox(
                width: 250,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedAlign(
                      alignment: _animationStep == 1 && _status == 'ongoing'
                          ? Alignment.centerLeft
                          : _status == 'finished' || _status == 'cancelled'
                              ? Alignment.centerRight
                              : Alignment.center,
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
            if (_reservation == null)
              SkeletonParagraph(
                style: const SkeletonParagraphStyle(lines: 2),
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              DateFormat("EEE, dd MMM yyyy\nhh:mm:ss", "id_ID")
                                  .format(DateTime.parse(
                                      _reservation!.timeCheckedIn!)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Check-out',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              (_reservation!.timeCheckedOut == null)
                                  ? 'Belum'
                                  : DateFormat(
                                          "EEE, dd MMM yyyy\nhh:mm:ss", 'id_ID')
                                      .format(DateTime.parse(
                                          _reservation!.timeCheckedOut!)),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Durasi',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (_reservation != null &&
                          _reservation!.status == 'ongoing')
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final duration = dateTimeCount(
                                _reservation!.timeCheckedIn!,
                                DateTime.now().toIso8601String());
                            return Text(
                              '${_reservation!.id} ${duration.inDays > 0 ? '${duration.inDays} Hari' : ''} ${duration.inHours > 0 ? '${duration.inHours} Jam' : ''} ${duration.inMinutes > 0 ? '${duration.inMinutes} Menit' : 'Baru Saja'}',
                            );
                          },
                        )
                      else
                        () {
                          final duration = dateTimeCount(
                              _reservation!.timeCheckedIn!,
                              _reservation!.timeCheckedOut ?? '');
                          return Text(
                            '${duration.inDays > 0 ? '${duration.inDays} Hari' : ''} ${duration.inHours > 0 ? '${duration.inHours} Jam' : ''} ${duration.inMinutes > 0 ? '${duration.inMinutes} Menit' : 'Baru Saja'}',
                          );
                        }()
                    ],
                  ),
                ],
              ),
            const Divider(),
            if (_reservation != null && _status == 'finished')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rincian Pembayaran',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total ongkos'),
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                            .format(_reservation!.charge ?? 0),
                      )
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
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                            .format(_reservation!.charge ?? 0),
                      )
                    ],
                  ),
                  const Divider(),
                ],
              ),
            if (_spot == null)
              SkeletonParagraph(
                style: const SkeletonParagraphStyle(lines: 2),
              )
            else
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
                    onPressed: () =>
                        Navigator.pushNamed(context, '/spot_detail'),
                  )
                ],
              ),
            const Divider(
              color: Colors.transparent,
            ),
            if (_reservation == null)
              const SkeletonLine()
            else
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.flag),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {}, child: const Text('Chat')),
                  ),
                  if (_status == 'finished')
                    const VerticalDivider(
                      color: Colors.transparent,
                    ),
                  if (_status == 'finished')
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {}, child: const Text('Beri Ulasan')),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
