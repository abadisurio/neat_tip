import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
