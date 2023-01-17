import 'dart:developer';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:neat_tip/screens/result_screen.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';
import 'package:neat_tip/widgets/debit_card.dart';

class SmartCard extends StatefulWidget {
  const SmartCard({Key? key}) : super(key: key);

  @override
  State<SmartCard> createState() => _SmartCardState();
}

class _SmartCardState extends State<SmartCard> {
  bool _isScanning = false;
  bool _isDetecting = false;
  CameraController? cameraController;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  startScanning() {
    cameraController?.startImageStream((image) {
      log('streaming');
      _processCameraImage(image);
    });
  }

  stopScanning() {
    cameraController?.stopImageStream();
  }

  void _itemDetected(String item) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ResultScreen(text: item)));
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    InputImage inputImage = getInputImage(image);
    _isDetecting = true;

    final RecognizedText recognisedText =
        await textRecognizer.processImage(inputImage);
    log('message');
    log('sini ${recognisedText.blocks}');

    for (TextBlock block in recognisedText.blocks) {
      log(block.text);
      if (block.text == "B 3853 KZA") {
        await cameraController?.stopImageStream();
        _itemDetected(block.text);
      }
    }
    setState(() {
      _isDetecting = false;
    });
  }

  InputImage getInputImage(CameraImage cameraImage) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    const InputImageRotation imageRotation = InputImageRotation.rotation0deg;

    const InputImageFormat inputImageFormat = InputImageFormat.nv21;

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
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
              child: CameraCapturer(controller: (controller) {
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
                child: Container(color: Colors.pink.shade600.withOpacity(0.4)),
              ),
            ),
            AnimatedOpacity(
              curve: Curves.easeOutCirc,
              opacity: _isScanning ? 0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: DebitCard(),
              ),
            ),
            AnimatedOpacity(
              curve: Curves.easeOutCirc,
              opacity: !_isScanning ? 0 : 1.0,
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
                        if (_isScanning) {
                          startScanning();
                        } else {
                          stopScanning();
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
