import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';

class ScanVehicle extends StatefulWidget {
  const ScanVehicle({Key? key}) : super(key: key);

  @override
  State<ScanVehicle> createState() => _ScanVehicleState();
}

class _ScanVehicleState extends State<ScanVehicle> with RouteAware {
  CameraController? cameraController;
  bool _isScanning = true;
  bool isScreenActive = false;
  bool isBatchScanning = false;
  String _detectedPlate = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeObserver =
        BlocProvider.of<RouteObserverCubit>(context).routeObserver;
    // log('routeObserver $routeObserver');
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPushNext() {
    log('didPushNext');
    if (mounted) {
      setState(() {
        isScreenActive = false;
      });
    }
    super.didPushNext();
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    log('didPopNext');
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          isScreenActive = true;
        });
      });
    }
    super.didPopNext();
  }

  onControllerMounted(controller) {
    setState(() {
      cameraController = controller;
    });
  }

  startScanning() {
    // setState(() {
    //   _isScanning = true;
    // });
    Future.delayed(const Duration(milliseconds: 1000), () {
      stopScanning();
      setState(() {
        _detectedPlate = "B 1234 ABC";
      });
    });
    // cameraController?.startImageStream((image) {
    //   if (_detectedPlate != "") {
    //     setState(() {
    //       _detectedPlate = "";
    //     });
    //     return;
    //   }
    //   if (!_isScanning) return;
    //   // if (!_isDetecting) _processCameraImage(image);
    // });
  }

  stopScanning() async {
    setState(() {
      _detectedPlate = "B 1234 ABC";
      _isScanning = false;
    });
    // textRecognizer.close();
    // if (cameraController!.value.isStreamingImages) {
    //   await cameraController?.stopImageStream();
    // }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() {
        _isScanning = true;
        isScreenActive = true;
      });
    });
    startScanning();
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (cameraController != null) {
    //   startScanning();
    // }
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: AnimatedContainer(
                      color: Colors.grey.shade900,
                      curve: Curves.easeOutCirc,
                      duration: const Duration(milliseconds: 500),
                      width: MediaQuery.of(context).size.width,
                      height:
                          _isScanning ? MediaQuery.of(context).size.width : 200,
                      child: Stack(
                        fit: StackFit.loose,
                        children: [
                          AnimatedOpacity(
                            opacity: _isScanning ? 1 : 0,
                            curve: Curves.easeOutCirc,
                            duration: const Duration(milliseconds: 500),
                            child: Transform.scale(
                              scale: 1.4,
                              child: CameraCapturer(
                                resolution: ResolutionPreset.low,
                                controller: (controller) {
                                  setState(() {
                                    cameraController = controller;
                                  });
                                },
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            curve: Curves.easeOutCirc,
                            opacity: _isScanning ? 1 : 0,
                            duration: const Duration(milliseconds: 500),
                            child: const Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  '\nPindai plat motor Pelanggan',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                            color: Colors.black, blurRadius: 3)
                                      ]),
                                )),
                          ),
                          AnimatedOpacity(
                            curve: Curves.easeOutCirc,
                            opacity: (_isScanning) ? 0 : 1,
                            duration: const Duration(milliseconds: 500),
                            child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '\n${isBatchScanning ? 'Beberapa ' : ''}Kendaraan Terdeteksi\n',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: const EdgeInsets.all(8),
                                          child: Text(_detectedPlate,
                                              style: TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade900)),
                                        ),
                                        if (isBatchScanning)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 16),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                boxShadow: !isBatchScanning
                                                    ? null
                                                    : [
                                                        const BoxShadow(
                                                            spreadRadius: -2,
                                                            color: Colors.white,
                                                            offset:
                                                                Offset(-8, -8)),
                                                        BoxShadow(
                                                            spreadRadius: -2,
                                                            color: Colors
                                                                .grey.shade900,
                                                            offset:
                                                                const Offset(
                                                                    -5, -5)),
                                                      ],
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Text(
                                              '+4',
                                              style: TextStyle(
                                                  color: Colors.grey.shade900,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                      ],
                                    ),
                                    const Divider(),
                                    if (!_isScanning && _detectedPlate != "")
                                      ElevatedButton(
                                          onPressed: startScanning,
                                          child: const Text('Tambah Lagi'))
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isScanning)
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              child: Column(children: [
                ListTile(
                  title: const Text('Pindai Sekaligus'),
                  trailing: Switch(
                    // This bool value toggles the switch.
                    value: isBatchScanning,
                    // overlayColor: overlayColor,
                    // trackColor: trackColor,
                    thumbColor:
                        const MaterialStatePropertyAll<Color>(Colors.black),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        isBatchScanning = !isBatchScanning;
                      });
                    },
                  ),
                ),
                if (isBatchScanning)
                  ElevatedButton(
                      onPressed: stopScanning, child: const Text('Selesai'))
              ]),
            ),
          ListView.builder(
              itemCount: 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: ((context, index) {
                return Card(
                  elevation: 0,
                  color: Colors.transparent,
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () {},
                    // dense: true,
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.motorcycle,
                      ),
                    ),
                    title: const Text('Kurnia Motor'),
                    subtitle: const Text('Dititipkan • Hari ini'),
                    trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rp6000',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            'Ditahan',
                            style: Theme.of(context).textTheme.caption,
                          )
                        ]),
                  ),
                );
              }))
        ],
      ),
    );
  }
}
