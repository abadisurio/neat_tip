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
  NeatTipUser? get currentUser => _currentUser;

  Future<void> initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    firebaseUser = FirebaseAuth.instance.currentUser;

    firestore = FirebaseFirestore.instance;
    final currentUser = sharedPreferences.getString('currentUser');

    try {
      firebaseUser
          ?.reload()
          .onError((error, stackTrace) => throw error.toString());
      log('currentUser $currentUser');
      if (currentUser == null && firebaseUser != null) {
        updateLocalInfo({});
      }
      final userFromFirestore = await fetchUserFromFirestore(firebaseUser!.uid);
      log('${userFromFirestore?.displayName}');
      if (currentUser != null) {
        _currentUser = NeatTipUser.fromJson(json.decode(currentUser));
        // if(userFromFirestore)
      }
    } catch (e) {
      log('$e');
    }
    // log('firebaseUser ${await  }');
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
      // updateInfo({});
      log('user $user');
    } catch (e) {
      log('sinii $e');
      rethrow;
    }
  }

  Future<void> updateDisplayName(String newInfo) async {
    await firebaseUser?.updateDisplayName(newInfo);
    updateLocalInfo({#displayName: newInfo});
  }

  Future<void> updateEmail(String newInfo) async {
    await firebaseUser?.updateEmail(newInfo);
    updateLocalInfo({#email: newInfo});
  }

  Future<void> updatePhotoURL(String newInfo) async {
    await firebaseUser?.updatePhotoURL(newInfo);
    updateLocalInfo({#photoURL: newInfo});
  }

  Future<void> updatePassword(String newInfo) async {
    await firebaseUser?.updatePassword(newInfo);
    // updateInfo({#email: newInfo});
  }

  // void updatePhoneNumber(PhoneAuthCredential newInfo) async {
  //   firebaseUser?.updatePhoneNumber(newInfo);
  // }

  Future<void> addUserToFirestore() async {
    try {
      log('currentUser $_currentUser');
      await firestore
          .collection("users")
          .doc(_currentUser!.id)
          .set(_currentUser!.toJson());
      // log('DocumentSnapshot added with ID');
      sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
    } catch (e) {
      // log('eee $e');
      throw Exception(e);
    }
  }

  Future<NeatTipUser?> fetchUserFromFirestore(String id) async {
    try {
      final fetch = await firestore.collection("users").doc(id).get();
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
        #createdAt: firebaseUser?.metadata.creationTime! ?? DateTime.now(),
        #updatedAt: DateTime.now(),
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
      // log('currentUser $_currentUser');
      // await firestore
      //     .collection("users")
      //     .doc(_currentUser!.id)
      //     .update(_currentUser!.toJson())
      //     .then((value) => log("DocumentSnapshot successfully updated!"),
      //         onError: (e) => log("Error updating document $e"));

      sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
    } catch (e) {
      log('eee $e');
      throw Exception(e);
    }
  }

  Future<void> updateUserToFirebase(Map<Symbol, dynamic> newInfo) async {
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
        #createdAt: firebaseUser?.metadata.creationTime! ?? DateTime.now(),
        #updatedAt: DateTime.now(),
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
      await firestore
          .collection("users")
          .doc(_currentUser!.id)
          .update(_currentUser!.toJson())
          .then((value) => log("DocumentSnapshot successfully updated!"),
              onError: (e) => log("Error updating document $e"));

      sharedPreferences.setString(
          'currentUser', json.encode(_currentUser?.toJson()));
    } catch (e) {
      log('eee $e');
      throw Exception(e);
    }
  }

  void addInfo(Map<Symbol, dynamic> newInfo) async {
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
        #createdAt: firebaseUser?.metadata.creationTime! ?? DateTime.now(),
        #updatedAt: DateTime.now(),
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
      await firestore
          .collection("users")
          .doc(_currentUser!.id)
          .set(_currentUser!.toJson());
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
