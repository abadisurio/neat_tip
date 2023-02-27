import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:neat_tip/utils/theme_data_dark.dart';

class Authorization extends StatefulWidget {
  const Authorization({Key? key}) : super(key: key);

  @override
  State<Authorization> createState() => _AuthorizationState();
}

enum RequestStatus { success, failed }

class _AuthorizationState extends State<Authorization> {
  final _formKey = GlobalKey<FormState>();
  late String? _permissionMessage;
  String _inputPin = '';
  RequestStatus? _requestStatus;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getDetail());
  }

  _getDetail() async {
    // await argument();
    log('_permissionMessage $_permissionMessage');
  }

  _cancel() {
    Navigator.pop(context);
  }

  _processAuthorization() async {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      log('_requestStatus $_requestStatus');
      await Navigator.pushNamed(context, '/state_loading', arguments: () async {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _requestStatus = RequestStatus.success;
        });
      });
      if (mounted) {
        log('_requestStatus $_requestStatus');
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _permissionMessage = ModalRoute.of(context)!.settings.arguments as String?;
    return Theme(
      data: getThemeDataDark(),
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black87,
          body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.symmetric(
                  // vertical: ,
                  horizontal: 16,
                ),

                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Divider(
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                  if (_permissionMessage != null)
                    Text(
                      '${_permissionMessage!} \n',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.white),
                    ),
                  const Text(
                    'Masukkan PIN Anda\n',
                    textAlign: TextAlign.center,
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tidak boleh kosong. Masukkan PIN Anda!';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _inputPin = value;
                          });
                        },
                        autofocus: _inputPin == '',
                        textAlign: TextAlign.center,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          prefixIcon: const SizedBox(
                            width: 75,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.send,
                            ),
                            onPressed: _processAuthorization,
                          ),
                        )),
                  ),
                  TextButton(onPressed: _cancel, child: const Text('Batalkan'))
                ]),
          ),
        ),
      ),
    );
  }
}
