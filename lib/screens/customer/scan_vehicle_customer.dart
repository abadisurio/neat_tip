import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/reservation.dart';
import 'package:neat_tip/models/spot.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/screens/customer/explore_spot.dart';
import 'package:neat_tip/screens/reservation_detail.dart';
import 'package:neat_tip/service/fb_cloud_functions.dart';
import 'package:neat_tip/utils/constants.dart';
import 'package:neat_tip/utils/date_time_count.dart';
import 'package:neat_tip/utils/get_input_image.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';
import 'package:neat_tip/widgets/vehicle_item.dart';
import 'package:skeletons/skeletons.dart';

class ScanVehicleCustomer extends StatefulWidget {
  final Reservation? reservation;
  const ScanVehicleCustomer({Key? key, this.reservation}) : super(key: key);

  @override
  State<ScanVehicleCustomer> createState() => _ScanVehicleCustomerState();
}

class _ScanVehicleCustomerState extends State<ScanVehicleCustomer>
    with RouteAware {
  CameraController? cameraController;
  bool _isScanning = true;
  bool isScreenActive = false;
  bool isBatchScanning = false;
  String _lastDetectedPlate = "";
  String _errorMessage = "";
  Duration _storeDuration = const Duration(seconds: 0);
  bool _isDetecting = false;
  Vehicle? _detectedVehicle;
  Reservation? _reservation;
  Spot? _detectedSpot;
  List<Map<String, dynamic>>? _prices;
  final bool _isInLocation = true;
  late VehicleListCubit _vehicleListCubit;
  late ReservationsListCubit _reservationsListCubit;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeObserver =
        BlocProvider.of<RouteObserverCubit>(context).routeObserver;
    // log('routeObserver $routeObserver');
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPushNext() {
    log('didPushNext');
    if (mounted) {
      setState(() {
        isScreenActive = false;
      });
    }
    super.didPushNext();
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    log('didPopNext');
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          isScreenActive = true;
        });
      });
    }
    super.didPopNext();
  }

  _onControllerMounted(controller) {
    setState(() {
      cameraController = controller;
    });
    _startScanning();
  }

  _startScanning() {
    int captureCount = 0;
    try {
      if (cameraController != null && cameraController!.value.isPreviewPaused) {
        cameraController?.resumePreview();
      }
      _detectedVehicle = null;
      setState(() {
        _isScanning = true;
      });
      // if(cameraController != null && !cameraController!.value.isStreamingImages)
      textRecognizer.close();
      cameraController?.startImageStream((image) {
        // sumpah ribet bat gambar pertama masih nympen bekas yg sebelomnya
        if (captureCount < 2) {
          captureCount += 1;
        }
        if (captureCount == 1) return;
        if (!_isScanning) return;
        if (!_isDetecting) _processCameraImage(image);
      });
      // Future.delayed(const Duration(seconds: 1), () {
      //   _itemDetected('B 3853 KZA');
      // });
    } catch (e) {
      log('e $e');
    }
  }

  _stopScanning() async {
    try {
      await cameraController?.stopImageStream();
      // await cameraController?.dispose();
      log('_lastDetectedPlate $_lastDetectedPlate');
      setState(() {
        _isScanning = false;
      });
      log('cameraController $cameraController');
      // await cameraController?.pausePreview();
    } catch (e) {
      log('e $e');
    }
  }

  _loadVehicle() {
    if (widget.reservation != null &&
        widget.reservation!.plateNumber != _lastDetectedPlate) {
      _setError('Bukan kendaraan yang ingin di-checkout');
      return;
    }
    final data = _vehicleListCubit.findByPlate(_lastDetectedPlate);
    if (data == null) {
      _setError('Kendaraan tidak dikenal');

      // _startScanning();
    } else {
      setState(() {
        _detectedVehicle = data;
      });
    }
  }

  _setError(String errorMessage) {
    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  _loadReservation() {
    final data = widget.reservation ??
        _reservationsListCubit.findByPlate(_lastDetectedPlate);
    if (data != null) {
      final duration =
          dateTimeCount(data.timeCheckedIn!, DateTime.now().toIso8601String());
      setState(() {
        _reservation = data;
        _storeDuration = duration;
      });
    }
    // log('_reservation ${_reservation?.toJson()}');
  }

  _loadSpot() {
    _detectedSpot = dummySpots[0];
  }

  _loadPrices() {
    final charge = (_storeDuration.inDays == 0 ? 1 : _storeDuration.inDays) *
        (_detectedSpot!.farePerDay ?? 0);
    // log('charge ${charge}');
    // (_detectedSpot!.farePerDay ?? 0) *
    //                             ()
    _prices = [
      {
        'name':
            'Ongkos Penitipan ${_storeDuration.inDays > 0 ? '${_storeDuration.inDays} Hari ' : ''}${_storeDuration.inHours > 0 ? '${_storeDuration.inHours % 24} Jam ' : ''}${_storeDuration.inMinutes > 0 ? '${_storeDuration.inMinutes % 60} Menit' : 'Baru Saja'}',
        'price': charge
      }
    ];
  }

  void _itemDetected(String plateNumber) async {
    log('plateNumber $plateNumber');
    setState(() {
      _lastDetectedPlate = plateNumber;
      // _detectedVehicle = _vehicleListCubit.state.first;
      // _reservation = _reservationsListCubit.state?.first;
    });
    _loadVehicle();
    if (_detectedVehicle != null) {
      await _stopScanning();
      _loadReservation();
      _loadSpot();
      _loadPrices();
      // _startScanning();
    }
  }

  void _processCameraImage(CameraImage image) async {
    _isDetecting = true;

    InputImage inputImage = getInputImage(image);
    try {
      final RecognizedText recognisedText = await textRecognizer
          .processImage(inputImage)
          .onError((error, stackTrace) {
        log('error $error');
        return RecognizedText(text: 'text', blocks: []);
      });
      if (recognisedText.blocks.isNotEmpty) {
        for (TextBlock block in recognisedText.blocks) {
          log('block.text ${block.text}');
          if (regexPlate.hasMatch(block.text)) {
            _itemDetected(block.text);
          }
        }
      }
      textRecognizer.close();
      _isDetecting = false;
    } catch (e) {
      log('error $e');
    }
  }

  _processCheckout() async {
    final result = await Navigator.pushNamed(context, '/authorization',
        arguments:
            'Konfirmasi pengambilan dan pembayaran penitipan motor di Kurnia Motor');
    if (mounted) {
      log('result $result');
      if (result == true) {
        _reservation!.spotId = _detectedSpot!.id;
        _reservation!.spotName = _detectedSpot!.name;
        _reservation!.status = 'finished';
        _reservation!.charge = (_prices?.fold(
            0,
            (previousValue, element) =>
                (previousValue ?? 0) +
                ((element['price'] as int) > 0
                    ? (element['price'] as int)
                    : 0)));
        _reservation!.timeCheckedOut = DateTime.now().toIso8601String();
        // log('_reservation ${_reservation!.toJson()}');
        await _reservationsListCubit.updateReservation(_reservation!);
        notifyRsvpFinished(_reservation!);
        // log('_reservation!.id ${_reservation!.id}');
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/reservation_detail', (route) => route.isFirst,
              arguments: ReservationArgument(
                  newlySucceded: true, reservationId: _reservation!.id));
        }
      }
    }
  }

  @override
  void initState() {
    _vehicleListCubit = context.read<VehicleListCubit>();
    _reservationsListCubit = context.read<ReservationsListCubit>();
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() {
        isScreenActive = true;
      });
    });
    // _startScanning();
    super.initState();
  }

  @override
  void dispose() {
    _stopScanning();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil Kendaraan'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AnimatedContainer(
              color: Colors.grey.shade900,
              curve: Curves.easeOutCirc,
              duration: const Duration(milliseconds: 500),
              width: MediaQuery.of(context).size.width,
              height:
                  !_isScanning ? 240 : MediaQuery.of(context).size.width - 32,
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Transform.scale(
                    scale: _isScanning ? 1.4 : 2,
                    child: !_isScanning
                        ? null
                        : CameraCapturer(
                            controller: _onControllerMounted,
                            resolution: ResolutionPreset.low),
                  ),
                  AnimatedOpacity(
                    curve: Curves.easeOutCirc,
                    opacity: _isScanning ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          '\nPindai plat motor Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 3)
                              ]),
                        )),
                  ),
                  AnimatedOpacity(
                    curve: Curves.easeOutCirc,
                    opacity: (_isScanning) ? 0 : 1,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.topLeft,
                        color: Colors.black87,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Kendaraan Terdeteksi',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isScanning = true;
                                      });
                                    },
                                    child: const Icon(Icons.replay_outlined))
                              ],
                            ),
                            const Divider(),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Theme.of(context).canvasColor,
                                ),
                                child: _detectedVehicle != null
                                    ? VehicleItem(vehicle: _detectedVehicle!)
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SkeletonListTile(
                                          hasSubtitle: true,
                                        ),
                                      ))
                          ],
                        )),
                  ),
                  if (_errorMessage != '')
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                        color: Colors.red.shade700,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCirc,
            secondCurve: Curves.easeOutCirc,
            duration: const Duration(milliseconds: 250),
            crossFadeState: _detectedVehicle == null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            // opacity: (_isScanning) ? 0 : 1,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mendeteksi kendaraan',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const Center(child: LinearProgressIndicator()),
                ],
              ),
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(
                  thickness: 0,
                ),
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
                        if (_detectedSpot != null)
                          Text(
                            _detectedSpot!.name ?? 'Mitra Neat Tip',
                          ),
                      ],
                    ),
                    ElevatedButton.icon(
                      label: Text(
                          '${_isInLocation ? 'Sudah di' : 'Jauh dari'} lokasi'),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/spot_detail'),
                      icon: Icon(_isInLocation
                          ? Icons.check
                          : Icons.wrong_location_rounded),
                    )
                  ],
                ),
                if (!_isInLocation)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pindai kendaraan Anda tepat pada lokasi penitipan!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                const Divider(),
                () {
                  log('_reservation ${_reservation?.toJson()}');
                  if (_reservation != null) {
                    return Row(
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
                              DateFormat('EEE, dd MMM yyyy', 'id_ID').format(
                                  DateTime.parse(
                                      _reservation!.timeCheckedIn ?? '')),
                            ),
                            StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 1)),
                              builder: (context, snapshot) {
                                return Text(
                                  '${_storeDuration.inDays > 0 ? '${_storeDuration.inDays} Hari ' : ''}${_storeDuration.inHours > 0 ? '${_storeDuration.inHours} Jam ' : ''}${_storeDuration.inMinutes > 0 ? '${_storeDuration.inMinutes} Menit' : 'Baru Saja'}',
                                );
                              },
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
                            if (_isInLocation)
                              Text(
                                DateFormat('EEE, dd MMM yyyy', 'id_ID')
                                    .format(DateTime.now()),
                              ),
                            Text(
                              _isInLocation ? 'Sekarang' : 'Nanti\n',
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return SizedBox(height: 100, child: SkeletonParagraph());
                  }
                }(),
                // const Divider(),
                // Text(
                //   'Penawaran',
                //   style: Theme.of(context).textTheme.titleSmall,
                // ),
                // TextButton(
                //   onPressed: () {},
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.discount,
                //         color: Colors.orange.shade800,
                //       ),
                //       const SizedBox(
                //         width: 12,
                //       ),
                //       const Expanded(child: Text('Dapatkan potongan harga')),
                //       const Icon(Icons.chevron_right)
                //     ],
                //   ),
                // ),
                const Divider(),
                Text(
                  'Rincian',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                // if (_reservation != null)
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //           'Ongkos Penitipan ${dateTimeCount(_reservation!.timeCheckedIn!, DateTime.now().toIso8601String(), onlyDay: true)}'),
                //       Text(
                //         NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                //             .format((_detectedSpot!.farePerDay ?? 0) *
                //                 (DateTime.now()
                //                     .difference(DateTime.parse(
                //                         _reservation!.timeCheckedIn!))
                //                     .inDays)),
                //       )
                //     ],
                //   ),
                if (_prices != null)
                  Column(
                    children: _prices!
                        .map(
                          (e) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e['name']),
                              Text(
                                NumberFormat.currency(
                                        locale: 'id_ID', symbol: 'Rp')
                                    .format(e['price']),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  ),

                // Row(
                //   children: [
                //     const Expanded(child: Text('Jumlah')),
                //     Text(
                //       'Rp${(prices.fold(0, (previousValue, element) => previousValue + ((element['price'] as int) > 0 ? (element['price'] as int) : 0)))} ',
                //       style: const TextStyle(
                //           decoration: TextDecoration.lineThrough,
                //           color: Colors.grey),
                //     ),
                //     Text(
                //         'Rp${(prices.fold(0, (previousValue, element) => previousValue + (element['price'] as int)))}')
                //   ],
                // ),
                const Divider(),
                Text(
                  'Pembayaran',
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.wallet,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: Text(
                              '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(5000)} Saldo')),
                      // Icon(Icons.chevron_right)
                    ],
                  ),
                ),
                // const ListTile(
                //   leading: Center(child: Icon(Icons.wallet)),
                //   dense: true,
                //   title: Text('Credit'),
                // ),
                // const ListTile(
                //   dense: true,
                //   title: Text('Credit'),
                // ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isInLocation ? Colors.green : Colors.red),
                    onPressed: _isInLocation ? _processCheckout : null,
                    child: Text(
                        'Bayar dan Ambil Kendaraan${_isInLocation ? '' : ' Ditunda'}'))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
