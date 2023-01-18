import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/vehicle.dart';

class VehicleListCubit extends Cubit<List<Vehicle>> {
  List<Vehicle> _dbList = [];
  late NeatTipDatabase _db;
  VehicleListCubit() : super([]);
  get collection => state;
  get length => state.length;

  // void increment() => emit(state.ad);
  // List<CameraDescription> _routeObserver = [];
  void initializeDB(NeatTipDatabase db) {
    _db = db;
    // emit(cameras);
  }

  Future<void> pushDataToDB() async {
    final newData = state.sublist(_dbList.length);
    for (var vehicle in newData) {
      await _db.vehicleDao.insertVehicle(vehicle);
    }
    // return ;
    // _db = db;
    // emit(cameras);
  }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.vehicleDao.findAllVehicle();
    _dbList = dataDB;
    emit([...state, ...dataDB]);
    // _db = db;
    // emit(cameras);
  }

  void setList(List<Vehicle> list) {
    emit(list);
    // state = list;
    // emit(cameras);
  }

  Vehicle findByIndex(int index) {
    return state.elementAt(index);
    // emit(cameras);
  }

  void removeByIndex(int index) {
    state.removeAt(index);
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

  // void addMultipleVehicle(List<Vehicle> vehicleList) {
  //   _collection.addAll(vehicleList);
  // }
  // void decrement() => emit(state - 1);
}
