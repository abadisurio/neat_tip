import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraCubit extends Cubit<List<CameraDescription>> {
  List<CameraDescription> cameraList = [];
  CameraCubit() : super([]);

  // void increment() => emit(state + 1);
  // List<CameraDescription> cameraList = [];
  void setCameraList(cameras) {
    cameraList = cameras;
    // emit(cameras);
  }
  // void decrement() => emit(state - 1);
}
