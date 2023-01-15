import 'package:flutter/material.dart';
import 'package:neat_tip/widgets/google_sign_in_button.dart';

enum AuthInputType { signin, signup, both }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

const List<Widget> authName = <Widget>[Text('Masuk'), Text('Daftar')];
const List<Map<String, dynamic>> signInFields = [
  {"fieldname": "Username", "value": null, "type": AuthInputType.both},
  {"fieldname": "Password", "value": null, "type": AuthInputType.both},
];
const List<Map<String, dynamic>> signUpFields = [
  {"fieldname": "Email", "value": null, "type": AuthInputType.signup},
  {"fieldname": "Nama", "value": null, "type": AuthInputType.signup},
];

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isShowSingUp = false;

  final List<bool> authType = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      isShowSingUp = authType[1];
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
                ...signInFields
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
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
                        ))
                    .toList()
              ]),
              AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCirc,
                  child: !isShowSingUp
                      ? const SizedBox()
                      : Column(mainAxisSize: MainAxisSize.min, children: [
                          ...signUpFields
                              .map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          hintText:
                                              'Masukkan ${e['fieldname']}',
                                          labelText: e['fieldname']),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Tidak Boleh Kosong. Masukkan ${e['fieldname']} Anda!';
                                        }
                                        return null;
                                      },
                                    ),
                                  ))
                              .toList()
                        ])),
              ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
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
              const GoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
