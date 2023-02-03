import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/models/neattip_user.dart';
import 'package:neat_tip/utils/firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NeatTipUserCubit extends Cubit<NeatTipUser?> {
  NeatTipUserCubit() : super(null);
  late SharedPreferences sharedPreferences;
  late FirebaseFirestore firestore;
  late User? firebaseUser;
  NeatTipUser? _currentUser;

  get firebaseCurrentUser => FirebaseAuth.instance.currentUser;
  get currentUser => _currentUser;

  Future<void> initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    firebaseUser = FirebaseAuth.instance.currentUser;
    final currentUser = sharedPreferences.getString('currentUser');
    firestore = FirebaseFirestore.instance;
    // log('firebaseUser $firebaseUser');
    log('currentUser $currentUser');
    if (firebaseUser != null) {
      updateInfo({});
    }
    if (currentUser != null) {
      _currentUser = NeatTipUser.fromJson(json.decode(currentUser));
    }
    // return NeatTipUser.fromJson(json.decode(currentUser));
  }

  Future signUpEmailPassword(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      user ??= await AppFirebase.signUpWithEmailPassword(email, password);
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
      updateInfo({});
      log('user $user');
    } catch (e) {
      log('sinii $e');
      rethrow;
    }
  }

  Future<void> updateDisplayName(String newInfo) async {
    await firebaseUser?.updateDisplayName(newInfo);
    updateInfo({#displayName: newInfo});
  }

  Future<void> updateEmail(String newInfo) async {
    await firebaseUser?.updateEmail(newInfo);
    updateInfo({#email: newInfo});
  }

  Future<void> updatePhotoURL(String newInfo) async {
    await firebaseUser?.updatePhotoURL(newInfo);
    updateInfo({#photoURL: newInfo});
  }

  Future<void> updatePassword(String newInfo) async {
    await firebaseUser?.updatePassword(newInfo);
    // updateInfo({#email: newInfo});
  }

  // void updatePhoneNumber(PhoneAuthCredential newInfo) async {
  //   firebaseUser?.updatePhoneNumber(newInfo);
  // }

  void updateInfo(Map<Symbol, dynamic> newInfo) {
    firebaseUser = FirebaseAuth.instance.currentUser;
    try {
      // final coba = newInfo.map((key, value) {
      //   return MapEntry(Symbol(key), value);
      // });
      final oldInfo = _currentUser
          ?.toJson()
          .map((key, value) => MapEntry(Symbol(key), value));
      log('oldInfo $oldInfo');
      _currentUser = Function.apply(NeatTipUser.new, [], {
        #createdAt:
            firebaseUser?.metadata.creationTime!.toIso8601String() ?? '',
        #updatedAt: DateTime.now().toUtc().toIso8601String(),
        #id: firebaseUser?.uid ?? '',
        #role: 'customer',
        #displayName: 'Neat Tip User',
        ...(oldInfo ?? {}),
        ...newInfo,
      });
      // currentUser = NeatTipUser(
      //     createdAt: firebaseUser?.metadata.creationTime.toString() ?? '',
      //     updatedAt: DateTime.now().toIso8601String(),
      //     id: firebaseUser?.uid ?? '',
      //     role: 'customer',
      //     fullName: 'bejo');
      log('currentUser $_currentUser');
      firestore.collection("users").add(_currentUser!.toJson()).then(
          (DocumentReference doc) =>
              log('DocumentSnapshot added with ID: ${doc.id}'));
      sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
    } catch (e) {
      log('eee $e');
      throw Exception(e);
    }
  }

  void addInfo(Map<Symbol, dynamic> newInfo) {
    firebaseUser = FirebaseAuth.instance.currentUser;
    try {
      // final coba = newInfo.map((key, value) {
      //   return MapEntry(Symbol(key), value);
      // });
      final oldInfo = _currentUser
          ?.toJson()
          .map((key, value) => MapEntry(Symbol(key), value));
      log('oldInfo $oldInfo');
      _currentUser = Function.apply(NeatTipUser.new, [], {
        #createdAt:
            firebaseUser?.metadata.creationTime!.toIso8601String() ?? '',
        #updatedAt: DateTime.now().toUtc().toIso8601String(),
        #id: firebaseUser?.uid ?? '',
        #role: 'customer',
        #displayName: 'Neat Tip User',
        ...(oldInfo ?? {}),
        ...newInfo,
      });
      // currentUser = NeatTipUser(
      //     createdAt: firebaseUser?.metadata.creationTime.toString() ?? '',
      //     updatedAt: DateTime.now().toIso8601String(),
      //     id: firebaseUser?.uid ?? '',
      //     role: 'customer',
      //     fullName: 'bejo');
      log('currentUser $_currentUser');
      firestore.collection("users").add(_currentUser!.toJson()).then(
          (DocumentReference doc) =>
              log('DocumentSnapshot added with ID: ${doc.id}'));
      sharedPreferences.setString(
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
    sharedPreferences.remove('currentUser');
  }

  // Future<void> updateData() {}

  // List<Vehicle> _dbList = [];
  // void initializeUser(NeatTipDatabase db) {
  //   _db = db;
  // }
}
