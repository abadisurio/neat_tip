import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/neattip_user.dart';

class SignOut extends StatefulWidget {
  const SignOut({Key? key}) : super(key: key);

  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> {
  @override
  void initState() {
    if (mounted) {
      BlocProvider.of<NeatTipUserCubit>(context).signOut();
    }
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sampai bertemu lagi!',
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Mengeluarkan akun',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const CircularProgressIndicator(),
        ],
      )),
    );
  }
}
