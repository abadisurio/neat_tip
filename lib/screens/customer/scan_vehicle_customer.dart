import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/spot.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/screens/customer/vehicle_list.dart';
import 'package:neat_tip/utils/constants.dart';
import 'package:neat_tip/utils/get_input_image.dart';
import 'package:neat_tip/widgets/vehicle_item.dart';
import 'package:path_provider/path_provider.dart';

class ScanVehicleCustomer extends StatefulWidget {
  const ScanVehicleCustomer({Key? key}) : super(key: key);

  @override
  State<ScanVehicleCustomer> createState() => _ScanVehicleCustomerState();
}

const List<Map<String, dynamic>> prices = [
  {'name': 'Biaya Penitipan Perhari', 'price': 5000},
  {'name': 'Potongan', 'price': -3000},
];

class _ScanVehicleCustomerState extends State<ScanVehicleCustomer>
    with RouteAware {
  CameraController? cameraController;
  bool _isScanning = true;
  bool isScreenActive = false;
  bool isBatchScanning = false;
  String _lastDetectedPlate = "";
  bool _isDetecting = false;
  Vehicle? _detectedVehicle;
  Spot? _detectedSpot;
  late VehicleListCubit _vehicleListCubit;
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

  onControllerMounted(controller) {
    setState(() {
      cameraController = controller;
    });
  }

  _startScanning() {
    _detectedVehicle = null;
    setState(() {
      _isScanning = true;
    });
    cameraController?.startImageStream((image) {
      // log('hehe');
      if (_lastDetectedPlate != "") {
        setState(() {
          _lastDetectedPlate = "";
        });
        return;
      }
      if (!_isScanning) return;
      if (!_isDetecting) _processCameraImage(image);
    });
    Future.delayed(const Duration(seconds: 1), () {
      _itemDetected('B 3853 KZA');
    });
  }

  stopScanning() async {
    log('_lastDetectedPlate $_lastDetectedPlate');
    setState(() {
      _isScanning = false;
    });
    // textRecognizer.close();
    // log('cameraController!.value.isStreamingImages ${cameraController!.value.isStreamingImages}');
    // if (cameraController!.value.isStreamingImages) {
    //   log('berenti');
    //   await cameraController?.stopImageStream();
    // }
  }

  void _itemDetected(String plateNumber) async {
    log('_vehicleListCubit.state ${_vehicleListCubit.state}');
    setState(() {
      _lastDetectedPlate = plateNumber;
      _detectedVehicle = _vehicleListCubit.state.first;
    });
    if (!isBatchScanning) {
      stopScanning();
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

  @override
  void initState() {
    _vehicleListCubit = context.read<VehicleListCubit>();
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() {
        isScreenActive = true;
      });
    });
    _startScanning();
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (cameraController != null) {
    //   _startScanning();
    // }
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
                  AnimatedOpacity(
                    curve: Curves.easeOutCirc,
                    opacity: _isScanning ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          '\nPindai plat motor',
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
                                    onPressed: _startScanning,
                                    child: const Icon(Icons.replay_outlined))
                              ],
                            ),
                            const Divider(),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                child: _detectedVehicle != null
                                    ? VehicleItem(vehicle: _detectedVehicle!)
                                    : null)
                          ],
                        )),
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
            firstChild: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 60,
                          width: 60,
                          child: ClipOval(
                            clipBehavior: Clip.hardEdge,
                            child: GestureDetector(
                              onTap: () {
                                log('tapp');
                              },
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CachedNetworkImage(
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl: FirebaseAuth
                                          .instance.currentUser?.photoURL ??
                                      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=240',
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          )),
                      const VerticalDivider(),
                      const CircleAvatar(
                        radius: 30,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward,
                            size: 30,
                          ),
                        ),
                      ),
                      const VerticalDivider(),
                      SizedBox(
                          height: 60,
                          width: 60,
                          child: ClipOval(
                            clipBehavior: Clip.hardEdge,
                            child: GestureDetector(
                              onTap: () {
                                log('tapp');
                              },
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CachedNetworkImage(
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl: FirebaseAuth
                                          .instance.currentUser?.photoURL ??
                                      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=240',
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
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
                        Text(
                          '2 Hari yang lalu',
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
                        const Text(
                          'Sekarang',
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Penawaran',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.discount,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(child: Text('Dapatkan potongan harga')),
                      Icon(Icons.chevron_right)
                    ],
                  ),
                ),
                const Divider(),
                Text(
                  'Rincian',
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
                              color:
                                  (isSurplus ? Colors.green.shade700 : null)),
                        )
                      ],
                    );
                  },
                ).toList(),
                Row(
                  children: [
                    const Expanded(child: Text('Jumlah')),
                    Text(
                      'Rp${(prices.fold(0, (previousValue, element) => previousValue + ((element['price'] as int) > 0 ? (element['price'] as int) : 0)))} ',
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey),
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

                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.wallet,
                        color: Colors.red.shade500,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      const Expanded(child: Text('Rp${5000} dari Saldo')),
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
                    onPressed: () {}, child: const Text('Ambil Kendaraan'))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
