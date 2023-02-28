import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:neat_tip/bloc/notification_list.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/service/fb_cloud_messaging.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  double _maxPage = 0;
  int _pageIndex = 0;
  int _vehicleLength = 0;
  late VehicleListCubit _vehicleListCubit;
  late ReservationsListCubit _reservationListCubit;

  Future<void> _reloadData() async {
    // await initializeFCM(cubit: context.read<NotificationListCubit>());
    await _reservationListCubit.reload();
    reloadFcmToken();
  }

  navigateToAuthPage() async {
    final isLoggedIn = await Navigator.pushNamed(context, '/auth') as bool;
    log('isLoggedIn $isLoggedIn');
    if (isLoggedIn && mounted) {
      await _vehicleListCubit.reload();
      setState(() {
        _vehicleLength = _vehicleListCubit.state.length;
        _maxPage += 1;
      });
    }
  }

  navigatoToPermissionPage() async {
    final isPermissionsAllowed =
        await Navigator.pushNamed(context, '/permission') as bool;
    log('isPermissionsAllowed $isPermissionsAllowed');
    if (isPermissionsAllowed && mounted) {
      setState(() {
        _maxPage += 1;
      });
    }
  }

  navigateToAddVehiclePage() async {
    final isVehicleAdded =
        await Navigator.pushNamed(context, '/vehicle_add') as bool?;
    log('isVehicleAdded $isVehicleAdded');
    if (isVehicleAdded ?? true && mounted) {
      setState(() {
        _maxPage += 1;
      });
    }
  }

  setSuspend(int page) {
    log('page $page');
    // bool suspend = false;
    // if (page < 2 && !_isLoggedIn) suspend = true;
    // if (page < 3 && !_isPermissionsAllowed) suspend = true;
    // if (page < 4 && !_isVehicleAdded) suspend = true;
    setState(() {
      _pageIndex = page;
      // _isPageSuspended = suspend;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vehicleListCubit = context.read<VehicleListCubit>();
      _reservationListCubit = context.read<ReservationsListCubit>();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // log('_isVehicleAdded $_isVehicleAdded');
    // log('_isLoggedIn $_isLoggedIn');

    return SafeArea(
      child: IntroductionScreen(
        rawPages: [
          const Center(
            child: Text('hehehe'),
          ),
          Center(
            child: _pageIndex <= _maxPage
                ? null
                : ElevatedButton(
                    onPressed: navigateToAuthPage,
                    child: const Text('Masuk'),
                  ),
          ),
          // if (_vehicleLength < 1)
          Center(
            child: _pageIndex <= _maxPage
                ? null
                : ElevatedButton(
                    onPressed: navigatoToPermissionPage,
                    child: const Text('izin'),
                  ),
          ),

          Center(
            child: (_pageIndex <= _maxPage)
                ? null
                : ElevatedButton(
                    onPressed: navigateToAddVehiclePage,
                    child: const Text('Tambah Kendaraan'),
                  ),
          ),
        ],
        onChange: setSuspend,
        showNextButton: _pageIndex <= _maxPage,
        showDoneButton: _pageIndex <= _maxPage || _vehicleLength > 0,
        // overrideNext: _setPage(1),
        // overrideBack: _setPage(-1),
        next: const Text("Lanjut"),
        back: const Text("Kembali"),
        done: const Text("Mulai Neat Tip"),
        freeze: true,
        showBackButton: true,
        allowImplicitScrolling: false,
        // allowImplicitScrolling: true,
        onDone: () async {
          // On button pressed
          // setState(() {

          // });
          await Navigator.pushNamed(context, '/state_loading',
              arguments: () async {
            await _reloadData();
          });
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/homeroot', (route) => false);
          }
        },
      ),
    );
  }
}
