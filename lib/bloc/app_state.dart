import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  late List<dynamic> configs;

  AppState({required this.configs});

  AppState.fromJson(Map<String, dynamic> json) {
    log('json ${json['configs']}');
    configs = json['configs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['configs'] = configs;
    return data;
  }
}

final defaultAppState = AppState(configs: [
  {"name": "Tema Gelap", "icon": 0xef9f, "value": false},
  {"name": "Kurangi Gerakan", "icon": 0xee77, "value": false},
]);

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(defaultAppState);
  late SharedPreferences sharedPreferences;
  // late FirebaseFirestore firestore;
  // late User? firebaseUser;
  // AppState? _currentState;

  // get firebaseCurrentUser => FirebaseAuth.instance.currentUser;
  get currentState => state;

  Future<void> initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    // sharedPreferences.remove('appState');
    final appState = sharedPreferences.getString('appState');
    log('appState $appState');
    if (appState == null) {
      emit(defaultAppState);
    } else {
      emit(AppState.fromJson(json.decode(appState)));
    }
    // log('firebaseUser ${await  }');
    // return NeatTipUser.fromJson(json.decode(currentUser));
  }

  void updateConfig(int index, Object value) {
    log('belom ${state.configs}');
    log('sini $index $value');
    state.configs[index]["value"] = value;
    sharedPreferences.setString('appState', json.encode(state.toJson()));
    emit(AppState(configs: state.configs));
    // emit(state);
  }
}
