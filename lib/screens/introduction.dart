import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:neat_tip/bloc/reservation_list.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/models/neattip_user.dart';
import 'package:neat_tip/service/fb_cloud_messaging.dart';
import 'package:video_player/video_player.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  double _maxPage = 0;
  int _pageIndex = 0;
  int _vehicleLength = 0;
  bool _isLoggedIn = false;
  bool _isPermissionsAllowed = false;
  NeatTipUser? _user;
  late VideoPlayerController _videoController;
  late VehicleListCubit _vehicleListCubit;
  late ReservationsListCubit _reservationListCubit;

  Future<void> _reloadData() async {
    // await initializeFCM(cubit: context.read<NotificationListCubit>());
    await _reservationListCubit.reload(role: _user!.role);
    PushNotificationService.reloadFcmToken();
  }

  navigateToAuthPage() async {
    _user = await Navigator.pushNamed(context, '/auth') as NeatTipUser?;
    // _user = await Navigator.pushNamed(context, '/auth') as NeatTipUser?;
    log('_user $_user');
    if (_user != null && mounted) {
      setState(() {
        _isLoggedIn = true;
        _maxPage += 1;
      });
      await _vehicleListCubit.reload();
      _vehicleLength = _vehicleListCubit.state.length;
    }
  }

  navigatoToPermissionPage() async {
    final isPermissionsAllowed =
        await Navigator.pushNamed(context, '/permission') as bool;
    log('isPermissionsAllowed $isPermissionsAllowed');
    if (isPermissionsAllowed && mounted) {
      setState(() {
        _isPermissionsAllowed = isPermissionsAllowed;
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

  Widget _get1Page() {
    return SafeArea(
        child: _videoController.value.isInitialized
            ? Padding(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    // fit: StackFit.passthrough,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 80,
                        child: FittedBox(
                          clipBehavior: Clip.hardEdge,
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController.value.size.width,
                            height: _videoController.value.size.height,
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                      ),
                      ListView(
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height / 2 - 150,
                          ),
                          Center(
                            child: SizedBox(
                                height: 100,
                                width: 100,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/logo_vanilla.png',
                                      fit: BoxFit.cover,
                                    ))),
                          ),
                          Text(
                            '\nNitip lewat Neat Tip aja',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          Text(
                            '\nscroll ke bawah buat kenalan',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: Colors.white),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Container());
  }

  Widget _get2Page() {
    return SafeArea(
        child: _isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Kamu sudah siap untuk meluncur!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    'Ketuk lanjutkan di bawah',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Masukkan akunmu yuk sebelum menggunakan Neat Tip',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: navigateToAuthPage,
                      child: const Text('Masuk'),
                    ),
                  ),
                ],
              ));
  }

  Widget _get3Page() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: _isPermissionsAllowed
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Mantap! Sekarang Neat Tip bisa berfungsi',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Ketuk lanjutkan di bawah',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Berikan izin agar Neat Tip dapat melihat dan membantumu menemukan tempat penitipan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: navigatoToPermissionPage,
                  child: const Text('izin'),
                ),
              ],
            ),
    ));
  }

  Widget _get4Page() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: !(_pageIndex <= _maxPage)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Kendaraanmu sukses ditambahkan ke Neat Tip',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Text(
                  'Ketuk mulai di bawah',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _pageIndex <= _maxPage
                      ? 'Kamu sudah mendaftarkan kendaraan, lewati jika tidak ingin tambah'
                      : 'Kamu perlu menambahkan kendaraan yang ingin dititipkan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: navigateToAddVehiclePage,
                  child: const Text('Tambah Kendaraan'),
                ),
              ],
            ),
    ));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vehicleListCubit = context.read<VehicleListCubit>();
      _reservationListCubit = context.read<ReservationsListCubit>();
    });
    _videoController = VideoPlayerController.network(
        'https://raw.githubusercontent.com/abadisurio/salemfood/main/public/video%20(2).mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
      });
    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log('_isVehicleAdded $_isVehicleAdded');
    // log('_isLoggedIn $_isLoggedIn');

    return IntroductionScreen(
      // globalBackgroundColor: Colors.transparent,
      rawPages: [
        _get1Page(),
        _get2Page(),
        _get3Page(),
        _get4Page(),
      ],
      onChange: setSuspend,
      showNextButton: _pageIndex <= _maxPage,
      showDoneButton: _pageIndex <= _maxPage || _vehicleLength > 0,
      // overrideNext: _setPage(1),
      // overrideBack: _setPage(-1),
      freeze: _pageIndex > _maxPage,
      next: const Text(
        "Lanjut",
        style: TextStyle(color: Colors.black),
      ),
      back: const Text(
        "Kembali",
        style: TextStyle(color: Colors.black),
      ),
      done: const Text(
        "Mulai Neat Tip",
        style: TextStyle(color: Colors.black),
      ),
      // freeze: true,
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
    );
  }
}
