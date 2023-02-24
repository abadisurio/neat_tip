import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/models/neattip_user.dart';
import 'package:neat_tip/service/fb_cloud_messaging.dart';
import 'package:neat_tip/utils/firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NeatTipUserCubit extends Cubit<NeatTipUser?> {
  NeatTipUserCubit() : super(null);
  late SharedPreferences _sharedPreferences;
  late FirebaseFirestore _firestore;
  late User? _firebaseUser;
  NeatTipUser? _currentUser;

  User? get firebaseCurrentUser => FirebaseAuth.instance.currentUser;
  // NeatTipUser? get currentUser => _currentUser;

  Future<void> initialize() async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    // _fcmToken = await FirebaseMessaging.instance.getToken();
    _firestore = FirebaseFirestore.instance;
    _sharedPreferences = await SharedPreferences.getInstance();
    final currentUser = _sharedPreferences.getString('currentUser');
    try {
      // _firebaseUser
      //     ?.reload()
      //     .onError((error, stackTrace) => throw error.toString());
      // log('currentUser $currentUser');

      // if (_firebaseUser != null) {
      //   updateLocalInfo({});
      // }
      if (currentUser != null && _firebaseUser != null) {
        _currentUser = NeatTipUser.fromJson(json.decode(currentUser));
        // if(userFromFirestore)
        updateLocalInfo({});
      }
    } catch (e) {
      log('$e');
    }
    emit(_currentUser);
    // log('_firebaseUser ${await  }');
    // return NeatTipUser.fromJson(json.decode(currentUser));
  }

  Future signUpEmailPassword(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      user ??= await AppFirebase.signUpWithEmailPassword(email, password);
      // reloadFcmToken();
      log('user $user');
    } catch (e) {
      log('$e');
    }
  }

  Future signInEmailPassword(String email, String password) async {
    try {
      final User? user =
          await AppFirebase.signInWithEmailPassword(email, password);
      if (user == null) {
        throw Exception('User not found!');
      }
      updateLocalInfo({});
      // reloadFcmToken();
      log('user $user');
    } catch (e) {
      log('sinii $e');
      rethrow;
    }
  }

  Future signInGoogle() async {
    try {
      final User? user = await AppFirebase.signInWithGoogle();
      if (user == null) {
        throw Exception('User not found!');
      }
      // reloadFcmToken();
      updateLocalInfo({});
      log('user $user');
    } catch (e) {
      log('sinii $e');
      rethrow;
    }
  }

  Future<void> updateDisplayName(String newInfo) async {
    await updateLocalInfo({#displayName: newInfo});
    _firebaseUser?.updateDisplayName(newInfo);
    updateUserToFirestore();
  }

  Future<void> updateEmail(String newInfo) async {
    _firebaseUser?.updateEmail(newInfo);
    // updateLocalInfo({#email: newInfo});
    // updateUserToFirestore();
  }

  Future<void> updatePhotoURL(String newInfo) async {
    await _firebaseUser?.updatePhotoURL(newInfo);
    // updateLocalInfo({#photoURL: newInfo});
    // updateUserToFirestore();
  }

  Future<void> updatePassword(String newInfo) async {
    await _firebaseUser?.updatePassword(newInfo);
    // updateInfo({#email: newInfo});
  }

  // void updatePhoneNumber(PhoneAuthCredential newInfo) async {
  //   _firebaseUser?.updatePhoneNumber(newInfo);
  // }

  Future<void> addUserToFirestore() async {
    try {
      log('currentUser $_currentUser');
      await _firestore
          .collection("users")
          .doc(_currentUser!.id)
          .set(_currentUser!.toJson());
      // log('DocumentSnapshot added with ID');
      _sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<NeatTipUser?> fetchUserFromFirestore(String id) async {
    try {
      final fetch = await _firestore.collection("users").doc(id).get();
      final data = fetch.data();
      if (data == null) {
        // log('sinii $data');
        return throw 'User exists, but User Info not found!';
      }
      return Function.apply(NeatTipUser.new, [],
          data.map((key, value) => MapEntry(Symbol(key), value)));
      // return NeatTipUser(createdAt: createdAt, updatedAt: updatedAt, id: id, role: role, displayName: displayName)
    } catch (e) {
      log('eee $e');
      // throw Exception(e);
    }
    return null;
  }

  Future<void> updateLocalInfo(Map<Symbol, dynamic> newInfo) async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    // log('_firebaseUser ${_firebaseUser}');
    final NeatTipUser? userFromFirestore =
        await fetchUserFromFirestore(_firebaseUser!.uid);
    // log('userFromFirestore ${userFromFirestore?.toJson()}');
    try {
      final oldInfo = _currentUser
          ?.toJson()
          .map((key, value) => MapEntry(Symbol(key), value));
      // log('newInfo $newInfo');

      _currentUser = Function.apply(NeatTipUser.new, [], {
        ...(oldInfo ?? {}),
        #createdAt: _firebaseUser?.metadata.creationTime!.toIso8601String() ??
            DateTime.now().toIso8601String(),
        #updatedAt: DateTime.now().toIso8601String(),
        #id: _firebaseUser?.uid ?? '',
        #role: userFromFirestore?.role ?? 'Pengguna',
        #displayName: userFromFirestore?.displayName ?? 'Neat Tip User',
        ...newInfo,
      });
      // log('_currentUser ${_currentUser?.toJson()}');
      await _sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
      emit(_currentUser);
    } catch (e) {
      log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> updateUserToFirestore() async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    try {
      log('_currentUser sini ${_currentUser?.toJson()}');
      await _firestore
          .collection("users")
          .doc(_currentUser!.id)
          .set(_currentUser!.toJson(), SetOptions(merge: true))
          // .update(_currentUser!.toJson())
          .then((value) => log("DocumentSnapshot successfully updated!"),
              onError: (e) => log("Error updating document $e"));

      _sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
    } catch (e) {
      log('eee $e');
      throw Exception(e);
    }
  }

  void addInfo(Map<Symbol, dynamic> newInfo) async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    try {
      // final coba = newInfo.map((key, value) {
      //   return MapEntry(Symbol(key), value);
      // });
      final oldInfo = _currentUser
          ?.toJson()
          .map((key, value) => MapEntry(Symbol(key), value));
      log('oldInfo $oldInfo');
      _currentUser = Function.apply(NeatTipUser.new, [], {
        #createdAt: _firebaseUser?.metadata.creationTime!.toIso8601String() ??
            DateTime.now().toIso8601String(),
        #updatedAt: DateTime.now().toIso8601String(),
        #id: _firebaseUser?.uid ?? '',
        #role: 'customer',
        #displayName: 'Neat Tip User',
        ...(oldInfo ?? {}),
        ...newInfo,
      });
      // currentUser = NeatTipUser(
      //     createdAt: _firebaseUser?.metadata.creationTime..toIso8601String()toString() ?? '',
      //     updatedAt:  DateTime.now().toIso8601String().toIso8601String(),
      //     id: _firebaseUser?.uid ?? '',
      //     role: 'customer',
      //     fullName: 'bejo');
      log('currentUser $_currentUser');
      await _firestore
          .collection("users")
          .doc(_currentUser!.id)
          .set(_currentUser!.toJson());
      _sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
    } catch (e) {
      log('eee $e');
      throw Exception(e);
    }
  }

  Future firebaseSignOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
    _sharedPreferences.remove('currentUser');
    _currentUser = null;
  }

  // Future<void> updateData() {}

  // List<Vehicle> _dbList = [];
  // void initializeUser(NeatTipDatabase db) {
  //   _db = db;
  // }
}
