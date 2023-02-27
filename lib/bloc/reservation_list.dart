import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/db/database.dart';
import 'package:neat_tip/models/reservation.dart';

class ReservationsListCubit extends Cubit<List<Reservation>?> {
  ReservationsListCubit() : super(null);
  // List<Reservation> _dbList = [];
  late NeatTipDatabase _db;
  late FirebaseFirestore _firestore;
  late String _userId;
  StreamSubscription<QuerySnapshot>? _streamSub;
  // get collection => state;
  // get length => state.length;

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
      await _listenDataFirestore();
      // _syncDataAndEmit([], dataFirestore);
    }
  }

  void _syncDataAndEmit(
      List<Reservation> dataLocalDB, List<Reservation> dataFirestore) {
    emit([...dataLocalDB, ...dataFirestore]);
  }

  Future<List<Reservation>> _pullDataFromDB() async {
    final dataDB = await _db.reservationsDao.findAllReservation();
    // _dbList = dataDB;
    // emit(dataDB);
    return dataDB;
    // emit([...state, ...dataDB]);
    // log('tarikMang $state');
  }

  Future<void> reload() async {
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _load();
  }

  Future<void> _updateDataFirestore(Reservation reservation) async {
    try {
      await _firestore
          .collection("reservation")
          .doc(reservation.id)
          .update(reservation.toJson())
          .onError((error, stackTrace) => log('error $error'));
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> _listenDataFirestore() async {
    try {
      final snapshot = _firestore
          .collection("reservation")
          .where("customerId", isEqualTo: _userId)
          // .where("status", isEqualTo: "ongoing")
          .limit(10)
          .snapshots();
      _streamSub = snapshot.listen(
        (event) async {
          final data = await Future.wait(event.docs.map((e) async {
            final spot = await _firestore
                .collection("spots")
                .doc("voX3FwgED5lggS4RnKaQ")
                .get();
            // await _firestore.collection("spots").doc(e.get("spotName")).get();
            log('spot.get("spotName") ${spot.get("name")}');

            return Reservation.fromJson({
              'id': e.id,
              'spotId': 'spotId',
              'hostUserId': 'hostUserId',
              'spotName': spot.get("name"),
              ...e.data(),
            });
          }).toList());
          _syncDataAndEmit([], data);
        },
      );
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  // Future<void> pushDataToDB() async {
  //   final newData = state.sublist(_dbList.length);
  //   for (var transactions in newData) {
  //     await _db.reservationsDao.insertReservation(transactions);
  //   }
  // }

  Future<void> pullDataFromDB() async {
    final dataDB = await _db.reservationsDao.findAllReservation();
    // _dbList = dataDB;
    emit(dataDB);
    // log('tarikMang $state');
  }

  void setList(List<Reservation> list) {
    emit(list);
  }

  Reservation? findByIndex(int index) {
    return state?.elementAt(index);
  }

  void removeByIndex(int index) {
    state?.removeAt(index);
    emit([...?state]);
  }

  Future<void> flushDataFromDB() async {
    _streamSub?.cancel();
    await _db.reservationsDao.flushAllReservation();
  }

  void removeById(String id) {
    final newList = state?.where((element) => element.id != id).toList();
    emit([...?newList]);
  }

  Future<Reservation?> findById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection("reservation").doc(id).get();
      if (docSnapshot.data() != null) {
        return Function.apply(Reservation.new, [], {
          #id: id,
          ...docSnapshot
              .data()!
              .map((key, value) => MapEntry(Symbol(key), value))
        });
      } else {
        return null;
      }
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
    // return state?.firstWhere((element) => element.id == id);
  }

  Reservation? findByPlate(String plateNumber) {
    final data = state?.where((element) => element.plateNumber == plateNumber);
    return (data != null && data.isNotEmpty) ? data.first : null;
  }

  void updateByIndex(int index, Reservation newReservation) {
    state?[index] = newReservation;
    emit([...?state]);
  }

  // void updateById(String id, Reservation newReservation) {
  //   final listIndex =
  //       state?.indexWhere((Reservation reservation) => reservation.id == id);
  //   state[listIndex] = newReservation;
  //   emit([...?state]);
  // }

  Future<Reservation> addReservation(Reservation reservation) async {
    final data = await _addDataToFirestore(reservation);
    await _db.reservationsDao.insertReservation(data);
    emit([...?state, data]);
    return data;
  }

  Future<void> updateReservation(Reservation newData) async {
    await _updateDataFirestore(newData);
    // await _db.reservationsDao.update(data);
    // final oldData = state
    //     ?.firstWhere(
    //       (element) => element.id == newData.id,
    //     )
    //     .toJson();
    // oldData?.keys.map((e) {
    //   oldData.update(e, (value) => newData.toJson()[e]);
    // });
    // emit([...?state]);
    // return data;
  }

  Future<void> finishReservation(Reservation reservation) async {
    _db.reservationsDao.finishReservationById(reservation.id);
    _updateDataFirestore(reservation);
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
