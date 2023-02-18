import 'dart:developer';
import 'dart:io';
// import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/vehicle.dart';
// import 'package:neat_tip/utils/firestore_delete_document.dart';
import 'package:path_provider/path_provider.dart';

class VehicleListCubit extends Cubit<List<Vehicle>> {
  List<Vehicle> _dbList = [];
  late NeatTipDatabase _db;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _firebaseStorage;
  late String _userId;
  VehicleListCubit() : super([]);
  get collection => state;
  get length => state.length;

  void initialize({required NeatTipDatabase localDB}) async {
    _firestore = FirebaseFirestore.instance;
    // _firestore.settings = Settings();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _firebaseStorage = FirebaseStorage.instance;
    _db = localDB;
    // final connectivityResult = await (Connectivity().checkConnectivity());
    await _pullDataFirestore();
    await _pullDataFromDB();
    // if (connectivityResult != ConnectivityResult.none) {
    //   // I am connected to a mobile network.
    // }
  }

  void reloadOnline() async {
    await _pushDataFirestore();
    // await _pullDataFirestore();
  }

  void end() async {
    await _pushDataFirestore();
    // await _pullDataFirestore();
  }

  Future<void> addDataToDB(Vehicle vehicle) async {
    await _db.vehicleDao.insertVehicle(vehicle);
  }

  Future<void> removeDataFromDB(Vehicle vehicle) async {
    await _db.vehicleDao.removeVehicle(vehicle);
  }

  Future<void> _addDataToFirestore(Vehicle vehicle) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    try {
      // log('vehicle $vehicle');
      String uploadedPhotoUrls = '';
      for (var photoName in vehicle.imgSrcPhotos.split(',')) {
        if (photoName != '') {
          log('photoName $photoName');
          final filePhoto = File(
              '${tempDir.path}${Platform.isIOS ? '/camera/pictures' : ''}/$photoName');
          log('filePhoto $filePhoto');
          final storageRef =
              _firebaseStorage.ref("vehicles/${vehicle.plate}/$photoName");
          await storageRef.putFile(filePhoto);
          final photoUrl = await storageRef.getDownloadURL();
          if (uploadedPhotoUrls != '') {
            uploadedPhotoUrls += ',';
          }
          uploadedPhotoUrls += photoUrl;
        }
      }
      // log('uploadedPhotoUrls $uploadedPhotoUrls');
      final oldInfo =
          vehicle.toJson().map((key, value) => MapEntry(Symbol(key), value));
      final Vehicle vehicleData = Function.apply(
          Vehicle.new, [], {...oldInfo, #imgSrcPhotos: uploadedPhotoUrls});
      log("vehicles/${vehicleData.ownerId}");
      await _firestore
          .collection("vehicles")
          .doc(vehicleData.plate)
          .set(vehicleData.toJson())
          .then((value) {
        // log('DocumentSnapshot added with ID ${value.id}');
      });
      await _firestore.collection("userVehicles").doc(_userId)
          // .update({"plates": []}).then((value) {
          .update({(state.length - 1).toString(): vehicle.plate}).then((value) {
        // log('DocumentSnapshot added with ID ${value.id}');
      });
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  // Future<void> _addUserVehicle(Vehicle vehicle) async {
  //   Directory tempDir = await getApplicationDocumentsDirectory();
  //   try {
  //     await _firestore
  //         .collection("userVehicles")
  //         .doc(_userId)
  //         .update({"plates": []}).then((value) {
  //       // .update({(state.length - 1).toString(): vehicle.plate}).then((value) {
  //       // log('DocumentSnapshot added with ID ${value.id}');
  //     });
  //   } catch (e) {
  //     // log('eee $e');
  //     throw Exception(e);
  //   }
  // }

  Future<bool> checkIsPlateExists(String plateNumber) async {
    // log('vehicle ${state.remove(vehicle)}');
    // state
    //     .asMap()
    //     .forEach((index, value) => ({index.toString(): value.toJson()}));
    try {
      final plate =
          await _firestore.collection("vehicles").doc(plateNumber).get();
      log('plate ${plate.exists} ');
      return plate.exists;
      // deleteFolder("vehicles/${vehicle.ownerId}/${vehicle.id}");
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> updateUserVehicles(Vehicle vehicle) async {
    log('vehicle ${state.remove(vehicle)}');
    state
        .asMap()
        .forEach((index, value) => ({index.toString(): value.toJson()}));
    try {
      await _firestore
          .collection("userVehicles")
          .doc(_userId)
          .update({'plates': state}).then((value) {
        // log('DocumentSnapshot added with ID ${value.id}');
      });
      // deleteFolder("vehicles/${vehicle.ownerId}/${vehicle.id}");
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  // Future<void> updateUserVehicles(Vehicle vehicle) async {
  //   log('vehicle ${vehicle.id}');
  //   try {
  //     await _firestore
  //         .collection("userVehicles")
  //         .doc(_userId)
  //         .update({(state.length - 1).toString(): vehicle.plate}).then((value) {
  //       // log('DocumentSnapshot added with ID ${value.id}');
  //     });
  //     // deleteFolder("vehicles/${vehicle.ownerId}/${vehicle.id}");
  //   } catch (e) {
  //     // log('eee $e');
  //     throw Exception(e);
  //   }
  // }
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

  Future<void> _pullDataFromDB() async {
    final dataDB = await _db.vehicleDao.findAllVehicle();
    _dbList = dataDB;
    emit(dataDB);
    // log('tarikMang $state');
  }

  Future<void> _pullDataFirestore() async {
    // String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection("userVehicles").doc(_userId).get();
      final plates = (snapshot.data() as Map)["plates"];
      log('plates $plates');
      final List<Vehicle> vehicleList = [];
      for (var element in (plates as List)) {
        final DocumentSnapshot vehicleData = await _firestore
            .collection("vehicles")
            .doc((element as String))
            .get();
        // log('vehicleData ${vehicleData.data()}');
        final vehicle = vehicleData.data() as Map<String, dynamic>?;
        if (vehicle != null) {
          vehicleList.add(Vehicle.fromJson((vehicle)));
        }
      }
      _dbList = vehicleList;
      log('vehicleList $vehicleList');
      emit(vehicleList);
      // log('data ${data[0].brand}');
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> _pushDataFirestore() async {
    // String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final Map<String, dynamic> mappedList = {
      for (var e in _dbList) e.id: e.toJson()
    };
    log('mappedList $mappedList');
    try {
      await _firestore.collection("vehicles").doc(_userId).set(mappedList);
      // emit(data);
      // log('data ${data[0].brand}');
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
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
    updateUserVehicles(vehicle);
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
    _addDataToFirestore(vehicle);
    emit([...state, vehicle]);
  }
}
