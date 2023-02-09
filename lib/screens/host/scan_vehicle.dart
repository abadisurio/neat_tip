import 'dart:developer';

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
  bool _isScanning = false;
  bool isScreenActive = false;
  bool batchScanning = false;

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
    setState(() {
      _isScanning = true;
    });
    // cameraController?.startImageStream((image) {
    //   // log('gambar baru');
    //   // log('_detectedPlate $_detectedPlate');
    //   // // log('_isDetecting $_isDetecting');
    //   // if (_detectedPlate != "") {
    //   //   setState(() {
    //   //     _detectedPlate = "";
    //   //   });
    //   //   return;
    //   // }
    //   // if (!_isScanning) return;
    //   // if (!_isDetecting) _processCameraImage(image);
    // });
  }

  stopScanning() async {
    // setState(() {
    //   _isScanning = false;
    // });
    // textRecognizer.close();
    // if (cameraController!.value.isStreamingImages) {
    //   await cameraController?.stopImageStream();
    // }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() {
        isScreenActive = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Transform.scale(
                    scale: 1.4,
                    // child: Container(color: Colors.grey),
                    child: Container(
                      color: Colors.black,
                      child: !isScreenActive
                          ? null
                          : CameraCapturer(
                              resolution: ResolutionPreset.low,
                              controller: onControllerMounted,
                            ),
                    )),
              ),
            ),
          ),
          ListTile(
            title: const Text('Pindai Sekaligus'),
            trailing: Switch(
              // This bool value toggles the switch.
              value: batchScanning,
              // overlayColor: overlayColor,
              // trackColor: trackColor,
              thumbColor: const MaterialStatePropertyAll<Color>(Colors.black),
              onChanged: (bool value) {
                // This is called when the user toggles the switch.
                setState(() {
                  batchScanning = !batchScanning;
                });
              },
            ),
          ),
          ListView.builder(
              itemCount: 5,
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
