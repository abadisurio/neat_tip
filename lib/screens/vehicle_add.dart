import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class VehicleAdd extends StatefulWidget {
  const VehicleAdd({super.key});

  @override
  State<VehicleAdd> createState() => VehicleAddState();
}

class VehicleAddState extends State<VehicleAdd> {
  final ItemScrollController _scrollController = ItemScrollController();
  CameraController? cameraController;
  List<String> imgSrcPhotos = [];
  List<File> imgFilePhotos = [];
  bool isScreenActive = true;

  void addPhotoField() {
    setState(() {
      imgSrcPhotos.add("hehe");
    });
    print('klik');
    Future.delayed(const Duration(milliseconds: 1000), () {
      _scrollController.scrollTo(
          index: imgSrcPhotos.length,
          curve: Curves.easeOutCirc,
          duration: const Duration(milliseconds: 1000));
    });
  }

  Future takePicture() async {
    if (cameraController != null) {
      addPhotoField();
    }
  }

  File choosePhoto() {
    return File('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kendaraan'),
      ),
      body: SafeArea(
          child: ListView(
        // padding: const EdgeInsets.all(16),
        children: [
          Text('${imgSrcPhotos.length}'),
          SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  ...imgSrcPhotos.map(
                    (e) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        width: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Transform.scale(
                                scale: 1.4,
                                child: Image.network(
                                    "https://ik.imagekit.io/zlt25mb52fx/ahmcdn/uploads/product/feature/fa-clickable-feature-motor-700x700pxl-ys-1-26092022-061617.jpg"),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade800,
                                      elevation: 0,
                                      shape: const CircleBorder()),
                                  onPressed: () {
                                    // print('index');
                                    // print(index);
                                    // _scrollController.scrollTo(
                                    //     index: imgSrcPhotos.length,
                                    //     curve: Curves.easeOutCirc,
                                    //     duration: const Duration(milliseconds: 1000));
                                    // addPhotoField();
                                    // navigator.pushNamed('/vehicleadd');
                                  },
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.grey.shade200,
                                  ),
                                  // child: Text('${item['name']}')
                                ),
                              ),
                            ],
                          ),
                        ),
                        // width: 110,
                      );
                    },
                  ),
                  Container(
                    // key: dataKey,
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // if (isScreenActive)
                          Transform.scale(
                            scale: 1.4,
                            child: CameraCapturer(
                              controller: (controller) {
                                // cameraController = controller;
                                // log('test $controller');
                                // if (controller.value.isInitialized) {
                                setState(() {
                                  cameraController = controller;
                                });
                                // }
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade800,
                                  elevation: 0,
                                  shape: const CircleBorder()),
                              onPressed: () {
                                // addPhotoField();
                                // captureImage(result);
                                // navigator.pushNamed('/vehicleadd');
                              },
                              child: Icon(
                                Icons.cancel_outlined,
                                color: Colors.grey.shade200,
                              ),
                              // child: Text('${item['name']}')
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: cameraController == null
                                ? null
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade800,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // takePicture();
                                      setState(() {
                                        isScreenActive = !isScreenActive;
                                      });
                                      await Navigator.of(context)
                                          .pushNamed('/vehiclelist');
                                      setState(() {
                                        isScreenActive = !isScreenActive;
                                      });
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.adjust,
                                          color: Colors.grey.shade200,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text('Ambil Gambar'),
                                      ],
                                    )
                                    // child: Text('${item['name']}')
                                    ),
                          ),
                        ],
                      ),
                    ),
                    // width: 110,
                  )
                ]),
              ))
        ],
      )),
    );
  }
}
