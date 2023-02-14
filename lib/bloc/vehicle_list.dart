import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/utils/firestore_delete_document.dart';
import 'package:path_provider/path_provider.dart';

class VehicleListCubit extends Cubit<List<Vehicle>> {
  List<Vehicle> _dbList = [];
  late NeatTipDatabase _db;
  late FirebaseFirestore firestore;
  late FirebaseStorage firebaseStorage;
  // late String userId;
  VehicleListCubit() : super([]);
  get collection => state;
  get length => state.length;

  void initializeDB(NeatTipDatabase db) {
    firestore = FirebaseFirestore.instance;
    firebaseStorage = FirebaseStorage.instance;
    // userId = FirebaseAuth.instance.currentUser!.uid;
    _db = db;
  }

  Future<void> addDataToDB(Vehicle vehicle) async {
    await _db.vehicleDao.insertVehicle(vehicle);
  }

  Future<void> removeDataFromDB(Vehicle vehicle) async {
    await _db.vehicleDao.removeVehicle(vehicle);
  }

  Future<void> addDataToFirestore(Vehicle vehicle) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    try {
      // log('vehicle $vehicle');
      String uploadedPhotoUrls = '';
      for (var photoName in vehicle.imgSrcPhotos.split(',')) {
        log('photoName $photoName');
        final filePhoto = File(
            '${tempDir.path}${Platform.isIOS ? '/camera/pictures' : ''}/$photoName');
        log('filePhoto $filePhoto');
        final storageRef = firebaseStorage
            .ref("vehicles/${vehicle.ownerId}/${vehicle.id}/$photoName");
        await storageRef.putFile(filePhoto);
        final photoUrl = await storageRef.getDownloadURL();
        if (uploadedPhotoUrls != '') {
          uploadedPhotoUrls += ',';
        }
        uploadedPhotoUrls += photoUrl;
      }
      // log('uploadedPhotoUrls $uploadedPhotoUrls');
      final oldInfo =
          vehicle.toJson().map((key, value) => MapEntry(Symbol(key), value));
      final vehicleData = Function.apply(
          Vehicle.new, [], {...oldInfo, #imgSrcPhotos: uploadedPhotoUrls});
      await firestore
          .collection("vehicles")
          .add(vehicleData.toJson())
          .then((value) {
        // log('DocumentSnapshot added with ID ${value.id}');
      });
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> removeDataFromFirestore(Vehicle vehicle) async {
    log('vehicle ${vehicle.id}');
    try {
      await firestore
          .collection("vehicles")
          .where("ownerId", isEqualTo: vehicle.ownerId)
          .where("id", isEqualTo: vehicle.id)
          .get()
          .then((snapshot) {
        for (var element in snapshot.docs) {
          element.reference.delete();
        }
      });
      deleteFolder("vehicles/${vehicle.ownerId}/${vehicle.id}");
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }
  // Future<void> pushDataToDB() async {
  //   for (var vehicle in state) {
  //     await _db.vehicleDao.insertVehicle(vehicle);
  //   }
  // }

  // Future<void> dropAndPushDataToDB() async {
  //   // _db.vehicleDao.d
  //   for (var vehicle in state) {
  //     await _db.vehicleDao.insertVehicle(vehicle);
  //   }
  // }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.vehicleDao.findAllVehicle();
    _dbList = dataDB;
    emit(dataDB);
    // log('tarikMang $state');
  }

  void setList(List<Vehicle> list) {
    emit(list);
  }

  Vehicle findByIndex(int index) {
    return state.elementAt(index);
  }

  void removeByIndex(int index) {
    log('sss $index');
    log('ssblum $state');
    state.removeAt(index);
    log('ssudah $state');
    emit([...state]);
  }

  Future<void> removeVehicle(Vehicle vehicle) async {
    final newList = state.where((element) => element != vehicle).toList();
    await removeDataFromDB(vehicle);
    removeDataFromFirestore(vehicle);
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

  Future<void> addVehicle(Vehicle vehicle) async {
    _dbList = [..._dbList, vehicle];
    await addDataToDB(vehicle);
    addDataToFirestore(vehicle);
    emit([...state, vehicle]);
  }
}
