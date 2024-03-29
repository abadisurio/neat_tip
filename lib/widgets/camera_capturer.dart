import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:neat_tip/bloc/camera.dart';

class CameraCapturer extends StatefulWidget {
  final Function(CameraController) controller;
  final ResolutionPreset resolution;
  const CameraCapturer(
      {super.key, required this.controller, required this.resolution});

  @override
  State<CameraCapturer> createState() => _CameraCapturerState();
}

class _CameraCapturerState extends State<CameraCapturer>
    with WidgetsBindingObserver {
  // bool _isPermissionGranted = false;
  List<CameraDescription> cameras = [];
  late List<CameraDescription> cameraList;

  // Add this controller to be able to control de camera
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraList = BlocProvider.of<CameraCubit>(context).cameraList;
    log('kamera nyalaa');
    _initCameraController(cameraList);
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
    // log('hehe ${widget.isScanning}');
    return Center(
        child: _cameraController != null
            ? CameraPreview(_cameraController!)
            : const CircularProgressIndicator());
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
      cameraList.first,
      widget.resolution,
      enableAudio: false,
    );

    log('_cameraController $_cameraController');

    if (mounted) {
      await _cameraController!.initialize().then((_) {
        widget.controller(_cameraController!);
        return;
      });
    }
    // Start streaming images from platform camera

    if (!mounted) {
      return;
    }
    setState(() {});
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
