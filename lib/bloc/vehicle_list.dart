import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/vehicle.dart';

class VehicleListCubit extends Cubit<List<Vehicle>> {
  List<Vehicle> _dbList = [];
  late NeatTipDatabase _db;
  VehicleListCubit() : super([]);
  get collection => state;
  get length => state.length;

  void initializeDB(NeatTipDatabase db) {
    _db = db;
  }

  Future<void> pushDataToDB() async {
    final newData = state.sublist(_dbList.length);
    for (var vehicle in newData) {
      await _db.vehicleDao.insertVehicle(vehicle);
    }
  }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.vehicleDao.findAllVehicle();
    _dbList = dataDB;
    emit([...state, ...dataDB]);
    log('tarikMang $state');
  }

  void setList(List<Vehicle> list) {
    emit(list);
  }

  Vehicle findByIndex(int index) {
    return state.elementAt(index);
  }

  void removeByIndex(int index) {
    state.removeAt(index);
    emit([...state]);
  }

  void removeById(String id) {
    final newList = state.where((element) => element.id != id).toList();
    emit([...newList]);
  }

  void updateByIndex(int index, Vehicle newVehicle) {
    state[index] = newVehicle;
    emit([...state]);
  }

  void updateById(String id, Vehicle newVehicle) {
    final listIndex = state.indexWhere((Vehicle vehicle) => vehicle.id == id);
    state[listIndex] = newVehicle;
    emit([...state]);
  }

  void addVehicle(Vehicle vehicle) {
    emit([...state, vehicle]);
  }
}
