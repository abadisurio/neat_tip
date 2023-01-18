import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/models/vehicle.dart';

class VehicleListCubit extends Cubit<List<Vehicle>> {
  List<Vehicle> _collection = [];
  VehicleListCubit() : super([]);
  get collection => state;
  get length => _collection.length;

  // void increment() => emit(state.ad);
  // List<CameraDescription> _routeObserver = [];
  void setList(List<Vehicle> list) {
    _collection = list;
    // emit(cameras);
  }

  Vehicle findByIndex(int index) {
    return _collection.elementAt(index);
    // emit(cameras);
  }

  void removeByIndex(int index) {
    _collection.removeAt(index);
  }

  // void length(Vehicle vehicle) {
  //   _collection.add(vehicle);
  // }
  void addVehicle(Vehicle vehicle) {
    log('sini');
    // state.add(vehicle);
    emit([...state, vehicle]);
    log('state sini $state');
    // return emit(_collection);
  }

  void addMultipleVehicle(List<Vehicle> vehicleList) {
    _collection.addAll(vehicleList);
  }
  // void decrement() => emit(state - 1);
}
