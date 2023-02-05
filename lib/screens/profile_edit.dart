import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/models/neattip_user.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> profileFields;
  late NeatTipUserCubit neatTipUserCubit;

  Map<String, TextEditingController> profileFieldControllers = {};
  bool _passwordVisible = false;

  @override
  void initState() {
    neatTipUserCubit = context.read<NeatTipUserCubit>();
    profileFields = [
      {
        "fieldname": "Nama Lengkap",
        "value": neatTipUserCubit.currentUser?.displayName,
        "type": TextInputType.text,
        "validator": (str) => true
      },
      {
        "fieldname": "Email",
        "value": neatTipUserCubit.firebaseCurrentUser?.email,
        "type": TextInputType.emailAddress,
        "validator": (str) => true
      },
    ];
    super.initState();
  }

  void submitProfile() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );

      final email = profileFieldControllers['Email']!.text;
      final displayName = profileFieldControllers['Nama Lengkap']!.text;
      // final password = profileFieldControllers['Password']!.text;
      FocusManager.instance.primaryFocus?.unfocus();
      try {
        log('hehehe ${neatTipUserCubit.firebaseCurrentUser?.displayName}');
        if (email != neatTipUserCubit.firebaseCurrentUser?.email ||
            displayName != neatTipUserCubit.firebaseCurrentUser?.displayName) {
          await Navigator.pushNamed(context, '/loading', arguments: () async {
            await neatTipUserCubit.updateEmail(email);
            await neatTipUserCubit.updateDisplayName(displayName);
          });
          if (mounted) {
            Navigator.pop(context);
          }
        }
        // if (isSingingUp) {
        //   await neatTipUserCubit.signUpEmailPassword(email, password);
        //   await neatTipUserCubit
        //       .updateDisplayName(profileFieldControllers['Nama']!.text);
        //   await neatTipUserCubit.updateLocalInfo({#role: selectedRole});
        //   await neatTipUserCubit.addUserToFirestore();
        // } else {
        //   await neatTipUserCubit.signInEmailPassword(email, password);
        // }
        // onSuccess();
      } catch (e) {
        // log('eeee $e');
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) => AlertDialog(
        //     title: const Text('Perhatian!'),
        //     content: const Text('Pengguna tidak ditemukan'),
        //     actions: <Widget>[
        //       TextButton(
        //         onPressed: () {
        //           Navigator.pop(context);
        //           setState(() {
        //             // isSingingUp = true;
        //             authType[0] = false;
        //             authType[1] = true;
        //           });
        //         },
        //         child: const Text('Buat Sekarang'),
        //       ),
        //       TextButton(
        //         onPressed: () => Navigator.pop(context, 'OK'),
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
      }

      // print(_formKey.currentState!.);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Profil'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
                onPressed: submitProfile, child: const Text('Simpan')),
          )
        ],
      ),
      body: BlocBuilder<NeatTipUserCubit, NeatTipUser?>(
          builder: (context, state) {
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: [
              ...profileFields.map((e) {
                final controller = profileFieldControllers.putIfAbsent(
                    e['fieldname'],
                    () => TextEditingController(text: e['value']));
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    obscureText: (e['obscure'] ?? false) && !_passwordVisible,
                    keyboardType: e['type'],
                    controller: controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Masukkan ${e['fieldname']}',
                      labelText: e['fieldname'],
                      suffixIcon: e['obscure'] == null
                          ? null
                          : IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tidak Boleh Kosong. Masukkan ${e['fieldname']} Anda!';
                      }
                      return null;
                    },
                  ),
                );
              }).toList()
            ],
          ),
        );
      }),
    );
  }
}
