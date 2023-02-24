import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/app_state.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignOut extends StatefulWidget {
  const SignOut({Key? key}) : super(key: key);

  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> {
  Future<void> _doSignOut() async {
    final NeatTipUserCubit neatTipUserCubit = context.read<NeatTipUserCubit>();
    final AppStateCubit appStateCubit = context.read<AppStateCubit>();
    final VehicleListCubit vehicleListCubit = context.read<VehicleListCubit>();
    final ReservationsListCubit reservationsListCubit =
        context.read<ReservationsListCubit>();
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("fcmToken");
    await neatTipUserCubit.signOut();
    await appStateCubit.flush();
    await vehicleListCubit.flushDataFromDB();
    await reservationsListCubit.flushDataFromDB();
    if (mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
      });
    }
  }

  @override
  void initState() {
    _doSignOut();
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
