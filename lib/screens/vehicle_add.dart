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
  // final ItemPositionsListener _scrollListener = ItemPositionsListener.create();
  static const double boxSize = 300;
  static const double contentGap = 16;
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
          duration: const Duration(milliseconds: 1500));
    });
  }

  Future takePicture() async {
    addPhotoField();
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
          Stack(
            children: [
              if (isScreenActive)
                Container(
                  margin: const EdgeInsets.only(left: contentGap),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade50)),
                  width: boxSize,
                  height: boxSize,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Transform.scale(
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
                  ),
                  // width: 110,
                ),
              SizedBox(
                  height: boxSize,
                  width: MediaQuery.of(context).size.width,
                  child: ScrollablePositionedList.builder(
                    padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width - 316),
                    reverse: true,
                    itemScrollController: _scrollController,
                    // itemPositionsListener: _scrollListener,
                    scrollDirection: Axis.horizontal,
                    itemCount: imgSrcPhotos.length + 1,
                    itemBuilder: ((context, index) {
                      if (index == imgSrcPhotos.length) {
                        return ClipPath(
                          clipper: ButtonClipper(),
                          child: Container(
                            color: Colors.grey.shade50,
                            width: boxSize + 16,
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.only(left: contentGap),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                        ),
                        width: boxSize + contentGap,
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
                    }),
                  )),
            ],
          ),

          // Text('${_scrollListener.itemPositions.value.first.}'),
          Container(
            padding: const EdgeInsets.fromLTRB(contentGap, 8.0, 0, 0),
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                onPressed: () async {
                  takePicture();
                  // setState(() {
                  //   isScreenActive = !isScreenActive;
                  // });
                  // await Navigator.of(context)
                  //     .pushNamed('/vehiclelist');
                  // setState(() {
                  //   isScreenActive = !isScreenActive;
                  // });
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
      )),
    );
  }
}

class ButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    // path.addRRect(RRect.fromRectAndRadius(Rect.largest, Radius.circular(32)));
    // path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // path.cubicTo(0, 1, size.width, size.height, 1, size.height);
    // path.cubicTo(size.width, size.height, size.width, 0, 0, 0);
    path.fillType = PathFillType.evenOdd;
    path.addRect(Rect.largest);
    // path.addOval(Rect.fromCircle(
    //     center: Offset(size.width / 2, size.height / 2), radius: 16));
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.height / 2),
        const Radius.circular(16)));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(ButtonClipper oldClipper) => false;
}
