// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/widgets/google_sign_in_button.dart';
import 'package:validators/validators.dart';

enum AuthInputType { signin, signup, both }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

const List<Widget> authName = <Widget>[Text('Masuk'), Text('Daftar')];
List<Map<String, dynamic>> signInFields = [
  {
    "fieldname": "Email",
    "value": null,
    "type": TextInputType.emailAddress,
    "validator": isEmail
  },
  {
    "fieldname": "Password",
    "value": null,
    "type": TextInputType.visiblePassword,
    "validator": (str) => true
  },
];
List<Map<String, dynamic>> signUpFields = [
  {
    "fieldname": "Nama",
    "value": null,
    "type": TextInputType.text,
    "validator": (str) => true
  },
];

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  late NeatTipUserCubit neatTipUserCubit;
  bool isSingingUp = false;
  bool isSuccess = false;
  Map<String, TextEditingController> authFieldControllers = {};

  final List<bool> authType = <bool>[true, false];

  void onSuccess() {
    setState(() {
      isSuccess = true;
    });
    Navigator.pop(context, true);
  }

  void submitAuth() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );

      final email = authFieldControllers['Email']!.text;
      final password = authFieldControllers['Password']!.text;

      try {
        if (isSingingUp) {
          await neatTipUserCubit.signUpEmailPassword(email, password);
          await neatTipUserCubit
              .updateDisplayName(authFieldControllers['Nama']!.text);
        } else {
          await neatTipUserCubit.signInEmailPassword(email, password);
        }
        onSuccess();
      } catch (e) {
        log('eeee $e');
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Perhatian!'),
            content: const Text('Pengguna tidak ditemukan'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    // isSingingUp = true;
                    authType[0] = false;
                    authType[1] = true;
                  });
                },
                child: const Text('Buat Sekarang'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      // print(_formKey.currentState!.);
    }
  }

  @override
  void initState() {
    super.initState();
    neatTipUserCubit = BlocProvider.of<NeatTipUserCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    isSingingUp = authType[1];
    return Scaffold(
      appBar: AppBar(),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, isSuccess);
          return isSuccess;
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                Center(
                  child: ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < authType.length; i++) {
                          authType[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderColor: Colors.grey.shade800,
                    selectedBorderColor: Colors.grey.shade800,
                    selectedColor: Colors.white,
                    fillColor: Colors.grey.shade800,
                    color: Colors.grey.shade600,
                    constraints: const BoxConstraints(
                      minHeight: 30.0,
                      minWidth: 80.0,
                    ),
                    isSelected: authType,
                    children: authName,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  ...signInFields.map((e) {
                    final controller = authFieldControllers.putIfAbsent(
                        e['fieldname'], () => TextEditingController());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        keyboardType: e['type'],
                        controller: controller,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Masukkan ${e['fieldname']}',
                            labelText: e['fieldname']),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tidak Boleh Kosong. Masukkan ${e['fieldname']} Anda!';
                          }
                          return null;
                        },
                      ),
                    );
                  }).toList()
                ]),
                AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCirc,
                    child: !isSingingUp
                        ? const SizedBox()
                        : Column(mainAxisSize: MainAxisSize.min, children: [
                            ...signUpFields.map((e) {
                              final controller =
                                  authFieldControllers.putIfAbsent(
                                      e['fieldname'],
                                      () => TextEditingController());
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextFormField(
                                  keyboardType: e['type'],
                                  controller: controller,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: 'Masukkan ${e['fieldname']}',
                                      labelText: e['fieldname']),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Tidak boleh kosong. Masukkan ${e['fieldname']} Anda!';
                                    }
                                    if (!e['validator'](value)) {
                                      return 'Format ${e['fieldname']} tidak sesuai';
                                    }
                                    return null;
                                  },
                                ),
                              );
                            }).toList()
                          ])),
                ElevatedButton(
                  onPressed: submitAuth,
                  child: const Text('Submit'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 2,
                        ),
                      ),
                      Text(
                        ' atau cara lain ',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                GoogleSignInButton(
                  onSuccess: onSuccess,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
