import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/utils/constants.dart';
import 'package:neat_tip/utils/get_input_image.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';

class ScanVehicle extends StatefulWidget {
  const ScanVehicle({Key? key}) : super(key: key);

  @override
  State<ScanVehicle> createState() => _ScanVehicleState();
}

class _ScanVehicleState extends State<ScanVehicle> with RouteAware {
  CameraController? cameraController;
  bool _isScanning = true;
  bool isScreenActive = false;
  bool isBatchScanning = false;
  String _lastDetectedPlate = "";
  bool _isDetecting = false;
  final List<String> _listDetectedPlate = [];
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

  confirmScan() {
    Navigator.pushNamed(context, '/confirm_scan_vehicle',
        arguments: {"scannedVehicleList": _listDetectedPlate});
  }

  startScanning() {
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
  }

  stopScanning() async {
    log('_lastDetectedPlate $_lastDetectedPlate');
    cameraController?.stopImageStream();
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
    log('siniiiwkwk');
    setState(() {
      _lastDetectedPlate = plateNumber;
      _listDetectedPlate.add(plateNumber);
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
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() {
        isScreenActive = true;
      });
    });
    startScanning();

    // Future.delayed(const Duration(seconds: 3), () {
    //   _itemDetected('B 3149 EGR');
    // });
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
    //   startScanning();
    // }
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              color: Colors.grey.shade900,
              // curve: Curves.easeOutCirc,
              // duration: const Duration(milliseconds: 500),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width - 32,
              child: Stack(
                fit: StackFit.loose,
                children: [
                  if (isScreenActive)
                    AnimatedOpacity(
                      opacity: _isScanning ? 1 : 0.1,
                      curve: Curves.easeOutCirc,
                      duration: const Duration(milliseconds: 500),
                      child: Transform.scale(
                        scale: 1.4,
                        child: CameraCapturer(
                          resolution: ResolutionPreset.low,
                          controller: (controller) {
                            setState(() {
                              cameraController = controller;
                            });
                            startScanning();
                          },
                        ),
                      ),
                    ),
                  AnimatedOpacity(
                    curve: Curves.easeOutCirc,
                    opacity: _isScanning ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          '\nPindai plat motor Pelanggan',
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
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\n${_listDetectedPlate.length > 1 ? 'Beberapa ' : ''}Kendaraan Terdeteksi\n',
                              style: const TextStyle(color: Colors.white),
                            ),
                            if (_listDetectedPlate.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(_listDetectedPlate.last,
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900)),
                                  ),
                                  if (_listDetectedPlate.length > 1)
                                    Container(
                                      margin: const EdgeInsets.only(left: 16),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: _listDetectedPlate.length <
                                                  2
                                              ? null
                                              : [
                                                  const BoxShadow(
                                                      spreadRadius: -2,
                                                      color: Colors.white,
                                                      offset: Offset(-8, -8)),
                                                  BoxShadow(
                                                      spreadRadius: -2,
                                                      color:
                                                          Colors.grey.shade900,
                                                      offset:
                                                          const Offset(-5, -5)),
                                                ],
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(
                                        '+${_listDetectedPlate.length - 1}',
                                        style: TextStyle(
                                            color: Colors.grey.shade900,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                ],
                              ),
                            const Divider(
                              thickness: 0,
                            ),
                            if (!_isScanning)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                      onPressed: startScanning,
                                      child: const Text('Tambah Lagi')),
                                  ElevatedButton(
                                      onPressed: confirmScan,
                                      child: const Text('Proses Kendaraan')),
                                ],
                              )
                          ],
                        )),
                  ),
                  // if (_isScanning)
                  //   SizedBox.expand(
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: [
                  //         Container(
                  //           decoration: BoxDecoration(
                  //               color: Theme.of(context).canvasColor,
                  //               borderRadius: BorderRadius.circular(8)),
                  //           padding: const EdgeInsets.all(8),
                  //           margin: const EdgeInsets.all(8),
                  //           child: Column(children: [
                  //             Row(
                  //               children: [
                  //                 const Expanded(
                  //                   child: Text(' Pindai Sekaligus'),
                  //                 ),
                  //                 if (isBatchScanning)
                  //                   ElevatedButton(
                  //                       onPressed: stopScanning,
                  //                       child: const Text('Selesai')),
                  //                 Switch(
                  //                   // This bool value toggles the switch.
                  //                   value: isBatchScanning,
                  //                   // overlayColor: overlayColor,
                  //                   // trackColor: trackColor,
                  //                   thumbColor:
                  //                       const MaterialStatePropertyAll<Color>(
                  //                           Colors.black),
                  //                   onChanged: (bool value) {
                  //                     // This is called when the user toggles the switch.
                  //                     setState(() {
                  //                       isBatchScanning = !isBatchScanning;
                  //                     });
                  //                   },
                  //                 ),
                  //               ],
                  //             ),
                  //           ]),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kendaraan Terdeteksi',
                  style: Theme.of(context).textTheme.headline6,
                ),
                ElevatedButton(
                    onPressed: confirmScan, child: const Text('Proses'))
              ],
            ),
          ),
          ListView.builder(
              itemCount: _listDetectedPlate.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                return Card(
                    elevation: 0,
                    color: Colors.white,
                    clipBehavior: Clip.hardEdge,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _listDetectedPlate[index],
                        style: TextStyle(
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.bold),
                      ),
                    ));
              }))
        ],
      ),
    );
  }
}
