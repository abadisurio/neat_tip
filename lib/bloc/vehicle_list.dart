import 'dart:developer';
import 'dart:io';
// import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    if (_userId != '') _load();
    // if (connectivityResult != ConnectivityResult.none) {
    //   // I am connected to a mobile network.
    // }
  }

  void _syncDataAndEmit(
      List<Vehicle> dataLocalDB, List<Vehicle> dataFirestore) {
    emit([...dataLocalDB, ...dataFirestore]);
  }

  Future<void> _load() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      final dataLocalDB = await _pullDataFromDB();
      log('dataLocalDB $dataLocalDB');
      // final dataFirestore = await _pullDataFirestore();
      _syncDataAndEmit(dataLocalDB, []);
    } else {
      final dataFirestore = await _pullDataFirestore();
      _syncDataAndEmit([], dataFirestore);
    }
  }

  Future<void> reload() async {
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _load();
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

  Future<void> flushDataFromDB() async {
    await _db.vehicleDao.flushAllVehicle();
  }

  _checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw 'User must connected to internet!';
    }
  }

  Future<void> _addDataToFirestore(Vehicle vehicle) async {
    await _checkConnection();
    Directory tempDir = await getTemporaryDirectory();
    try {
      // log('vehicle $vehicle');
      for (var photoName in vehicle.imgSrcPhotos.split(',')) {
        log('photoName $photoName');
        if (photoName != '') {
          final filePhoto = File(
              '${tempDir.path}${Platform.isIOS ? '/camera/pictures' : ''}/$photoName');
          log('filePhoto $filePhoto');
          final storageRef =
              _firebaseStorage.ref("vehicles/${vehicle.plate}/$photoName");
          await storageRef.putFile(filePhoto);
        }
      }
      // log('uploadedPhotoUrls $uploadedPhotoUrls');
      // final oldInfo =
      //     vehicle.toJson().map((key, value) => MapEntry(Symbol(key), value));
      // final Vehicle vehicleData = Function.apply(
      //     Vehicle.new, [], {...oldInfo, #imgSrcPhotos: uploadedPhotoUrls});
      log("vehicles/${vehicle.ownerId}");
      await _firestore
          .collection("vehicles")
          .doc(vehicle.plate)
          .set(vehicle.toJson())
          .then((value) {
        // log('DocumentSnapshot added with ID ${value.id}');
      });
      await _firestore
          .collection("userVehicles")
          .doc(_userId)
          .set({"plates": state.map((e) => e.plate).toList()}).then((value) {
        // .update({(state.length - 1).toString(): vehicle.plate}).then((value) {
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

  bool checkIsPlateAdded(String plateNumber) {
    // log('vehicleExiststs ${state.where((element) => element.id == plateNumber).isNotEmpty}');
    log('state ${state.map((e) => e.plate)}');
    return state.where((element) => element.plate == plateNumber).isNotEmpty;
  }

  Future<void> addUserVehicles(String plateNumber) async {
    try {
      final plate =
          await _firestore.collection("vehicles").doc(plateNumber).get();
      // log('plate ${plate.exists} ');
      final Map<String, dynamic>? data = plate.data();
      if (data != null) {
        final newVehicle = Vehicle.fromJson(data);
        await addVehicle(newVehicle);
        await _downloadImages(newVehicle);
        updateUserVehicles();
      }
      // deleteFolder("vehicles/${vehicle.ownerId}/${vehicle.id}");
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> updateUserVehicles() async {
    log('vehicleList $state');
    final newUserVehicles = state.map((e) => e.plate).toList();
    log('vehicleList $newUserVehicles');
    // state
    //     .asMap()
    //     .forEach((index, value) => ({index.toString(): value.toJson()}));
    try {
      await _firestore
          .collection("userVehicles")
          .doc(_userId)
          .set({'plates': newUserVehicles}).then((value) {
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

  Future<List<Vehicle>> _pullDataFromDB() async {
    final dataDB = await _db.vehicleDao.findAllVehicle();
    _dbList = dataDB;
    // emit(dataDB);
    return dataDB;
    // emit([...state, ...dataDB]);
    // log('tarikMang $state');
  }

  Future<List<Vehicle>> _pullDataFirestore() async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection("userVehicles").doc(_userId).get();
      final plates = snapshot.data() as Map?;
      log('plates $plates');
      final List<Vehicle> vehicleList = [];
      if (plates != null) {
        for (var element in (plates["plates"] as List)) {
          final DocumentSnapshot vehicleSnapshot = await _firestore
              .collection("vehicles")
              .doc((element as String))
              .get();
          // log('vehicleData ${vehicleData.data()}');
          final vehicleData = vehicleSnapshot.data() as Map<String, dynamic>?;
          if (vehicleData != null) {
            final vehicle = Vehicle.fromJson(vehicleData);
            // String imgSrcPhotos = '';
            await _downloadImages(vehicle);
            // for (var photoName in (vehicle.imgSrcPhotos).split(',')) {
            //   // log('photoName $photoName');
            //   if (photoName != '') {
            //     final filePhoto = await File(
            //             '${tempDir.path}${Platform.isIOS ? '/camera/pictures' : ''}/$photoName')
            //         .create();
            //     log('filePhoto $filePhoto');
            //     final storageRef = _firebaseStorage
            //         .ref("vehicles/${vehicle.plate}/$photoName");
            //     log('message $storageRef');
            //     final imageBytes = await storageRef.getData();
            //     if (imageBytes != null) {
            //       filePhoto.writeAsBytes(imageBytes.toList());
            //     }
            //     // final photoUrl = await storageRef.getDownloadURL();
            //   }
            // }

            // var myFile = File('${dir.path}/${vehicle['imgSrcPhotos']}');
            log('vehicle $vehicle');

            vehicleList.add(vehicle);
          }
        }
        _dbList = vehicleList;
        log('vehicleList $vehicleList');
        // emit([...state, ...vehicleList]);
        // emit(vehicleList);
      }
      return vehicleList;
      // log('data ${data[0].brand}');
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> _downloadImages(Vehicle vehicle) async {
    Directory tempDir = await getTemporaryDirectory();
    for (var photoName in (vehicle.imgSrcPhotos).split(',')) {
      // log('photoName $photoName');
      if (photoName != '') {
        final filePhoto = await File(
                '${tempDir.path}${Platform.isIOS ? '/camera/pictures' : ''}/$photoName')
            .create();
        log('filePhoto $filePhoto');
        final storageRef =
            _firebaseStorage.ref("vehicles/${vehicle.plate}/$photoName");
        log('message $storageRef');
        final imageBytes = await storageRef.getData();
        if (imageBytes != null) {
          filePhoto.writeAsBytes(imageBytes.toList());
        }
        // final photoUrl = await storageRef.getDownloadURL();
      }
    }
  }

  Future<void> _pushDataFirestore() async {
    // String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // final Map<String, dynamic> mappedList = {
    //   for (var e in _dbList) e.id: e.toJson()
    // };
    // log('mappedList $mappedList');
    // try {
    //   await _firestore.collection("vehicles").doc(_userId).set(mappedList);
    //   // emit(data);
    //   // log('data ${data[0].brand}');
    // } catch (e) {
    //   // log('eee $e');
    //   throw Exception(e);
    // }
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
    await _checkConnection();
    final newList = state.where((element) => element != vehicle).toList();
    await removeDataFromDB(vehicle);
    emit([...newList]);
    updateUserVehicles();
  }

  void updateByIndex(int index, Vehicle newVehicle) {
    state[index] = newVehicle;
    emit([...state]);
  }

  // void updateById(String id, Vehicle newVehicle) {
  //   final listIndex = state.indexWhere((Vehicle vehicle) => vehicle.id == id);
  //   state[listIndex] = newVehicle;
  //   emit([...state]);
  // }

  Future<void> addVehicle(Vehicle vehicle) async {
    _dbList = [..._dbList, vehicle];
    await addDataToDB(vehicle);
    emit([...state, vehicle]);
  }

  Future<void> enrollVehicle(Vehicle vehicle) async {
    _addDataToFirestore(vehicle);
    await addVehicle(vehicle);
  }
}
