import 'package:flutter/material.dart';
import 'package:neat_tip/widgets/google_sign_in_button.dart';

enum AuthInputType { signin, signup, both }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

const List<Widget> authName = <Widget>[Text('Masuk'), Text('Daftar')];
const List<Map<String, dynamic>> authFields = [
  {"fieldname": "Email", "value": null, "type": AuthInputType.signup},
  {"fieldname": "Nama", "value": null, "type": AuthInputType.signup},
  {"fieldname": "Username", "value": null, "type": AuthInputType.both},
  {"fieldname": "Password", "value": null, "type": AuthInputType.both},
];

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

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
              ...authFields.map(
                (e) {
                  return Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      curve: Curves.easeOutCirc,
                      height: (authType[1] ||
                              (e['type'] == AuthInputType.signin ||
                                  e['type'] == AuthInputType.both))
                          ? 70
                          : 0,
                      child: !(authType[1] ||
                              (e['type'] == AuthInputType.signin ||
                                  e['type'] == AuthInputType.both))
                          ? const SizedBox()
                          : TextFormField(
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: (authType[1] ||
                                                (e['type'] ==
                                                        AuthInputType.signin ||
                                                    e['type'] ==
                                                        AuthInputType.both))
                                            ? const Color(0xFF000000)
                                            : Colors.transparent),
                                  ),
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
                    ),
                  );
                },
              ).toList(),
              const GoogleSignInButton(),
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
                child: Row(children: const [
                  Icon(Icons.logo_dev),
                  Expanded(
                      child: Center(child: Text('Masuk menggunakan Google')))
                ]),
              ),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
