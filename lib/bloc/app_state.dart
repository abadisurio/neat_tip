import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  // late List<dynamic> configs;
  late DateTime updatedAt;
  late bool darkMode;
  late bool reduceMotion;

  AppState(
      {required this.darkMode,
      required this.reduceMotion,
      required this.updatedAt});

  Map<String, dynamic> get members => ({
        'updatedAt': DateTime.now(),
        'darkMode': darkMode,
        'reduceMotion': reduceMotion,
      });
  Map<String, dynamic> get visibleMembers => ({
        'darkMode': {
          'name': 'Mode Gelap',
          'value': darkMode,
        },
      });

  AppState.fromJson(Map<String, dynamic> json) {
    darkMode = json['darkMode'];
    reduceMotion = json['reduceMotion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['darkMode'] = darkMode;
    data['reduceMotion'] = reduceMotion;
    return data;
  }
}

final defaultAppState =
    AppState(darkMode: false, reduceMotion: false, updatedAt: DateTime.now());

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(defaultAppState);
  late SharedPreferences sharedPreferences;
  get currentState => state;

  Future<void> initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    // sharedPreferences.remove('appState');
    final appState = sharedPreferences.getString('appState');
    // log('appState ${appState}');
    if (appState == null) {
      emit(defaultAppState);
    } else {
      emit(AppState.fromJson(json.decode(appState)));
    }
  }

  void updateConfig(String configName, dynamic value) {
    final AppState newState = Function.apply(AppState.new, [], {
      ...state.members.map((key, oldValue) => MapEntry(Symbol(key), oldValue)),
      Symbol(configName): value
    });
    sharedPreferences.setString('appState', json.encode(newState.toJson()));
    emit(newState);
    uploadConfigToFirestore();
  }

  Future<void> uploadConfigToFirestore() async {
    await FirebaseFirestore.instance
        .collection('appState')
        .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
        .set(state.members)
        .onError((error, stackTrace) => throw '$error');
  }
}
