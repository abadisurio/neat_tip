import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/utils/constants.dart';
import 'package:neat_tip/utils/get_input_image.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';
import 'package:neat_tip/widgets/debit_card.dart';

class SmartCard extends StatefulWidget with RouteAware {
  const SmartCard({Key? key}) : super(key: key);

  @override
  State<SmartCard> createState() => _SmartCardState();
}

class _SmartCardState extends State<SmartCard> with RouteAware {
  bool isScreenActive = false;
  late List<Vehicle> vehicleList;
  late List<String> plateNumbers;
  String _detectedPlate = "";
  bool _isScanning = false;
  bool _isDetecting = false;
  CameraController? cameraController;
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

  startScanning() {
    cameraController?.startImageStream((image) {
      log('gambar baru');
      log('_detectedPlate $_detectedPlate');
      // log('_isDetecting $_isDetecting');
      if (_detectedPlate != "") {
        setState(() {
          _detectedPlate = "";
        });
        return;
      }
      if (!_isScanning) return;
      if (!_isDetecting) _processCameraImage(image);
    });
  }

  stopScanning() async {
    setState(() {
      _isScanning = false;
    });
    textRecognizer.close();
    if (cameraController!.value.isStreamingImages) {
      await cameraController?.stopImageStream();
    }
  }

  void _itemDetected(String plateNumber) async {
    setState(() {
      // _isScanning = false;
      _detectedPlate = plateNumber;
    });
    stopScanning();
    // await cameraController?.stopImageStream();
  }

  void _processCameraImage(CameraImage image) async {
    InputImage inputImage = getInputImage(image);

    _isDetecting = true;
    // log('message ${inputImage.type}');

    try {
      final RecognizedText recognisedText = await textRecognizer
          .processImage(inputImage)
          .onError((error, stackTrace) {
        log('error $error');
        return RecognizedText(text: 'text', blocks: []);
      });

      log('recognisedText ${recognisedText.blocks}');
      if (recognisedText.blocks.isNotEmpty) {
        for (TextBlock block in recognisedText.blocks) {
          log('block.text ${block.text}');
          if (regexPlate.hasMatch(block.text)) {
            for (var number in plateNumbers) {
              log('number $number');
              if (number.replaceAll(' ', '') ==
                  block.text.replaceAll(' ', '')) {
                _itemDetected(number);
                // _isDetecting = false;
              }
            }
          }
        }
      }

      _isDetecting = false;
    } catch (e) {
      log('error $e');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        isScreenActive = true;
      });
    });
    vehicleList = context.read<VehicleListCubit>().state;
    plateNumbers = vehicleList.map((Vehicle e) => e.plate).toList();
    // setState(() {
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final navigator = Navigator.of(context);
    // log('plateNumberswww $plateNumbers');
    log('isScreenActive $isScreenActive');
    return AnimatedContainer(
      margin: EdgeInsets.only(
        top: _isScanning ? 0 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5)
        ],
      ),
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 500),
      width: _isScanning
          ? MediaQuery.of(context).size.width - 16
          : MediaQuery.of(context).size.width - 48,
      height: _isScanning
          ? MediaQuery.of(context).size.width - 16
          : MediaQuery.of(context).size.width * 0.55,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          fit: StackFit.loose,
          children: [
            AnimatedScale(
              scale: _isScanning ? 1.5 : 2.1,
              curve: Curves.easeOutCirc,
              duration: const Duration(milliseconds: 500),
              child: !isScreenActive
                  ? null
                  : CameraCapturer(
                      resolution: ResolutionPreset.low,
                      controller: (controller) {
                        setState(() {
                          cameraController = controller;
                        });
                      }),
            ),
            AnimatedOpacity(
              curve: Curves.easeOutCirc,
              opacity: _isScanning ? 0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 30.0,
                  sigmaY: 30.0,
                ),
                child: Container(color: Colors.blue.shade600.withOpacity(0.4)),
              ),
            ),
            AnimatedOpacity(
              curve: Curves.easeOutCirc,
              opacity: _isScanning || _detectedPlate != "" ? 0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: DebitCard(),
              ),
            ),
            AnimatedOpacity(
              curve: Curves.easeOutCirc,
              opacity: _detectedPlate != ""
                  ? 0
                  : _isScanning
                      ? 1
                      : 0,
              duration: const Duration(milliseconds: 500),
              child: const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    '\nPindai plat motor Anda',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 3)]),
                  )),
            ),
            AnimatedOpacity(
              curve: Curves.easeOutCirc,
              opacity: _detectedPlate == "" ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    '\nKendaraan Terdeteksi\n\n$_detectedPlate',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 3)]),
                  )),
            ),
            SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isScanning = !_isScanning;
                        });
                        if (Platform.isAndroid) {
                          if (_isScanning) {
                            startScanning();
                          } else {
                            stopScanning();
                          }
                        }
                      },
                      child: Icon(_isScanning
                          ? Icons.keyboard_double_arrow_up_outlined
                          : Icons.fit_screen_outlined),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
