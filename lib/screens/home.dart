import 'dart:developer';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:neat_tip/screens/result_screen.dart';
import 'package:neat_tip/widgets/dashboard_menu.dart';
import 'package:neat_tip/widgets/dashboard_wallet.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  bool _isDetecting = false;
  bool _isScanning = false;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  late final Future<void> _future;

  // Add this controller to be able to control de camera
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Text Recognition Sample'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: Container(
                      // width: double.infinity,
                      // decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.black45, width: 2),
                      //     borderRadius: BorderRadius.circular(30.0)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          children: [
                            // Show the camera feed behind everything
                            if (_isPermissionGranted)
                              FutureBuilder<List<CameraDescription>>(
                                future: availableCameras(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    _initCameraController(snapshot.data!);

                                    // return Center(child: CameraPreview(_cameraController!));
                                    // return Center(
                                    //     child: CameraPreview(_cameraController!));
                                    return AnimatedScale(
                                        scale: _isScanning ? 1.05 : 1.1,
                                        curve: Curves.easeOut,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Center(
                                            child: CameraPreview(
                                                _cameraController!)));
                                  } else {
                                    return const LinearProgressIndicator();
                                  }
                                },
                              ),
                            AnimatedPositioned(
                                curve: Curves.easeOut,
                                top: _isScanning ? 400 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 30.0,
                                      sigmaY: 30.0,
                                    ),
                                    child: Container(
                                      height: 1000,
                                      width: 1000,
                                      color: Colors.black26,
                                    ),
                                  ),
                                )),
                            // ClipRect(
                            //   child: AnimatedPositioned(
                            //     curve: Curves.easeOut,
                            //     top: _isScanning ? 100 : 200.0,
                            //     duration: const Duration(milliseconds: 200),
                            //     child: BackdropFilter(
                            //       filter: ImageFilter.blur(
                            //         sigmaX: 30.0,
                            //         sigmaY: 30.0,
                            //       ),
                            //       child: Container(
                            //         height: 100,
                            //         color: Colors.blue.withOpacity(0.2),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // ClipRect(
                            //   child: BackdropFilter(
                            //     filter: ImageFilter.blur(
                            //       sigmaX: 30.0,
                            //       sigmaY: 30.0,
                            //     ),
                            //     child: Container(
                            //       height: double.infinity,
                            //       color: _isScanning
                            //           ? Colors.transparent
                            //           : Colors.blue.withOpacity(0.2),
                            //     ),
                            //   ),
                            // ),
                            _isPermissionGranted
                                ? Column(
                                    children: [
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 30.0),
                                        child: Center(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isScanning = !_isScanning;
                                              });
                                            },
                                            child: Icon(_isScanning
                                                ? Icons.camera_alt_outlined
                                                : Icons.camera_alt),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 24.0, right: 24.0),
                                      child: const Text(
                                        'Camera permission denied',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const DashboardWallet(),
                ),
                const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const DashboardMenu(),
                ),
              ],
            ),
          ),
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
              _processCameraImage(image);
            }) // image processing and text recognition.
        );
    // Start streaming images from platform camera

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    // getting InputImage from CameraImage
    if (!_isScanning) return;
    if (_isDetecting) return;
    InputImage inputImage = getInputImage(image);
    _isDetecting = true;
    final navigator = Navigator.of(context);

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
        setState(() {
          _isScanning = false;
        });
        await navigator.push(
          MaterialPageRoute(
            builder: (BuildContext context) => ResultScreen(text: block.text),
          ),
        );
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
