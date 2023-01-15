import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScanner extends StatefulWidget {
  final bool isScanning;
  final Future Function(String result) onComplete;
  const CameraScanner(
      {super.key, required this.isScanning, required this.onComplete});

  @override
  State<CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScanner>
    with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  bool _isDetecting = false;
  bool _isScanning = true;
  List<CameraDescription> cameras = [];
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  late final Future<void> _future;

  // Add this controller to be able to control de camera
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
    // setState(() {
    //   _isScanning = widget.isScanning;
    // });
  }

  // We should stop the camera once this widget is disposed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }

  // Starts and stops the camera according to the lifecycle of the app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }

    // if (state == AppLifecycleState.resumed) {
    //   _initCameraController(cameras);
    // }
  }

  @override
  Widget build(BuildContext context) {
    log('hehe ${widget.isScanning}');
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          fit: StackFit.loose,
          children: [
            // Show the camera feed behind everything
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // setState(() {
                    //   cameras = snapshot.data!;
                    // });
                    _initCameraController(snapshot.data!);

                    // return Center(child: CameraPreview(_cameraController!));
                    return Center(child: CameraPreview(_cameraController!));
                    // return Center(child: Text('${widget.isScanning}'));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            if (!_isPermissionGranted)
              Center(
                child: Container(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: const Text(
                    'Camera permission denied',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await _cameraController!.initialize().then((_) async =>
            await _cameraController!.startImageStream((CameraImage image) {
              // print(widget.isScanning);
              // print(_isScanning);
              if (widget.isScanning && _isScanning) {
                // print('sinisss');
                _processCameraImage(image);
              }
            }) // image processing and text recognition.
        );
    // Start streaming images from platform camera

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _itemDetected(String item) async {
    // print("panggil 2");
    setState(() {
      _isScanning = false;
    });
    _cameraController!.stopImageStream();
    await widget.onComplete(item);
    _startCamera();
    setState(() {
      _isScanning = true;
    });
  }

  void _processCameraImage(CameraImage image) async {
    // getting InputImage from CameraImage
    // if (!widget.isScanning) return;
    if (_isDetecting) return;
    InputImage inputImage = getInputImage(image);
    _isDetecting = true;

    final RecognizedText recognisedText =
        await textRecognizer.processImage(inputImage);
    log('message');
    log('sini ${recognisedText.blocks}');
    // Using the recognised text.
    for (TextBlock block in recognisedText.blocks) {
      // recognizedText = block.text + " ";
      log(block.text);
      if (block.text == "B 3853 KZA") {
        // textRecognizer.close();
        // widget.isScanning = false;
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

    const InputImageRotation imageRotation =
        // InputImageRotationMethods.fromRawValue(
        // _camera!.description.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    const InputImageFormat inputImageFormat =
        // InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
        InputImageFormat.nv21;

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
}
