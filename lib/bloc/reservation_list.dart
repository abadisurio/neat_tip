import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/reservation.dart';

class ReservationsListCubit extends Cubit<List<Reservation>> {
  List<Reservation> _dbList = [];
  late NeatTipDatabase _db;
  late FirebaseFirestore _firestore;
  late String _userId;
  ReservationsListCubit() : super([]);
  get collection => state;
  get length => state.length;

  void initializeDB(NeatTipDatabase db) {
    _db = db;
  }

  void initialize({required NeatTipDatabase localDB}) async {
    _firestore = FirebaseFirestore.instance;
    // _firestore.settings = Settings();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // _firebaseStorage = FirebaseStorage.instance;
    _db = localDB;
    if (_userId != '') _load();
    // if (connectivityResult != ConnectivityResult.none) {
    //   // I am connected to a mobile network.
    // }
  }

  Future<void> _load() async {
    final connectivityResult = _checkConnection();
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

  void _syncDataAndEmit(
      List<Reservation> dataLocalDB, List<Reservation> dataFirestore) {
    emit([...dataLocalDB, ...dataFirestore]);
  }

  Future<List<Reservation>> _pullDataFromDB() async {
    final dataDB = await _db.reservationsDao.findAllReservation();
    _dbList = dataDB;
    // emit(dataDB);
    return dataDB;
    // emit([...state, ...dataDB]);
    // log('tarikMang $state');
  }

  Future<List<Reservation>> _pullDataFirestore() async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection("userVehicles").doc(_userId).get();
      final plates = snapshot.data() as Map?;
      log('plates $plates');
      final List<Reservation> vehicleList = [];
      if (plates != null) {
        for (var element in (plates["plates"] as List)) {
          final DocumentSnapshot vehicleSnapshot = await _firestore
              .collection("vehicles")
              .doc((element as String))
              .get();
          // log('vehicleData ${vehicleData.data()}');
          final vehicleData = vehicleSnapshot.data() as Map<String, dynamic>?;
          if (vehicleData != null) {
            final vehicle = Reservation.fromJson(vehicleData);
            // String imgSrcPhotos = '';
            // await _downloadImages(vehicle);
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

  Future<void> pushDataToDB() async {
    final newData = state.sublist(_dbList.length);
    for (var transactions in newData) {
      await _db.reservationsDao.insertReservation(transactions);
    }
  }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.reservationsDao.findAllReservation();
    _dbList = dataDB;
    emit(dataDB);
    // log('tarikMang $state');
  }

  void setList(List<Reservation> list) {
    emit(list);
  }

  Reservation findByIndex(int index) {
    return state.elementAt(index);
  }

  void removeByIndex(int index) {
    state.removeAt(index);
    emit([...state]);
  }

  Future<void> flushDataFromDB() async {
    await _db.reservationsDao.flushAllReservation();
  }

  void removeById(String id) {
    final newList = state.where((element) => element.id != id).toList();
    emit([...newList]);
  }

  void updateByIndex(int index, Reservation newReservation) {
    state[index] = newReservation;
    emit([...state]);
  }

  void updateById(String id, Reservation newReservation) {
    final listIndex =
        state.indexWhere((Reservation reservation) => reservation.id == id);
    state[listIndex] = newReservation;
    emit([...state]);
  }

  Future<void> addReservation(Reservation reservation) async {
    final data = await _addDataToFirestore(reservation);
    await _db.reservationsDao.insertReservation(data);
    emit([...state, data]);
  }

  _checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw 'User must connected to internet!';
    }
    return connectivityResult;
  }

  Future<Reservation> _addDataToFirestore(Reservation reservation) async {
    await _checkConnection();
    // Directory tempDir = await getTemporaryDirectory();
    try {
      log("reservation ${reservation.toJson()}");
      // await _firestore
      //     .collection("vehicles")
      //     .doc(reservation.plateNumber)
      //     .set(reservation.toJson())
      //     .then((value) {
      //   // log('DocumentSnapshot added with ID ${value.id}');
      // });
      // await _firestore.collection("userVehicles").doc(_userId).set(
      //     {"plates": state.map((e) => e.plateNumber).toList()}).then((value) {
      //   // .update({(state.length - 1).toString(): vehicle.plate}).then((value) {
      //   // log('DocumentSnapshot added with ID ${value.id}');
      // });
      final containedUser = await _firestore
          .collection("userVehicles")
          .where("plates", arrayContains: reservation.plateNumber)
          .get();
      log('containedUser.docs ${containedUser.docs.first.id}');
      final jsonReservation = {
        ...reservation.toJson(),
        'status': 'ongoing',
        'customerId': containedUser.docs.first.id
      };
      jsonReservation.removeWhere((key, value) => key == 'id');
      final firestoreReservation = await _firestore
          .collection("reservation")
          // .doc(_userId)
          // .collection(collectionPath)
          .add(jsonReservation);
      final data = await firestoreReservation.get();
      log('data ${data.id}');
      return Function.apply(Reservation.new, [], {
        ...data.data()!.map((key, value) => MapEntry(Symbol(key), value)),
        #id: data.id,
        #spotId: 'hhhh',
        #hostUserId: _userId,
        // ...reservation
      });
      // return Reservation(
      //     id: 'id',
      //     spotId: 'spotId',
      //     hostUserId: 'hostUserId',
      //     customerId: containedUser.docs.first.id,
      //     plateNumber: 'plateNumber');
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }
}
