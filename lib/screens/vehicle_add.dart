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
  bool isCapturing = false;
  bool isFlashOn = false;

  Future takePicture() async {
    setState(() {
      isCapturing = true;
    });
    if (cameraController != null) {
      final photo = await cameraController!.takePicture();
      log('photo $photo');
      setState(() {
        imgSrcPhotos.add(photo.path);
        imgFilePhotos.add(File(photo.path));
      });
      addPhotoField();
    }
  }

  void addPhotoField() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      _scrollController.scrollTo(
          index: imgFilePhotos.length,
          curve: Curves.easeOutCirc,
          duration: const Duration(milliseconds: 1500));
    });

    setState(() {
      isCapturing = false;
    });
  }

  removePhoto(int index) {
    log('$index');
    // _scrollController.scrollTo(
    //     index: index + 1,
    //     curve: Curves.easeOutCirc,
    //     duration: const Duration(milliseconds: 1500));
    // Future.delayed(const Duration(milliseconds: 1000), () {
    // });
    setState(() {
      imgFilePhotos.removeAt(index);
    });
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
            fit: StackFit.loose,
            children: [
              if (isScreenActive)
                Container(
                  margin: const EdgeInsets.only(left: contentGap * 0.5),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade50)),
                  width: boxSize,
                  height: boxSize,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Transform.scale(
                      scale: 1.5,
                      child: Center(
                        child: CameraCapturer(
                          resolution: ResolutionPreset.medium,
                          controller: (controller) {
                            // cameraController = controller;
                            // log('test $controller');
                            // if (controller.value.isInitialized) {
                            controller.setFlashMode(FlashMode.off);
                            setState(() {
                              cameraController = controller;
                            });
                            // }
                          },
                        ),
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
                    itemCount: imgFilePhotos.length + 1,
                    itemBuilder: ((context, index) {
                      if (index == imgFilePhotos.length) {
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
                              Image.file(
                                imgFilePhotos[index],
                                fit: BoxFit.cover,
                              ),
                              Text('$index'),
                              Align(
                                alignment: Alignment.topRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade800,
                                      elevation: 0,
                                      shape: const CircleBorder()),
                                  onPressed: () {
                                    removePhoto(index);
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
            child: Row(
              children: [
                if (cameraController != null)
                  ElevatedButton(
                      onPressed: () async {
                        if (!isCapturing) {
                          takePicture();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCapturing ? Icons.adjust : Icons.circle,
                            color: Colors.grey.shade200,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(isCapturing ? 'Tahan' : 'Ambil Gambar'),
                        ],
                      )
                      // child: Text('${item['name']}')
                      ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  onPressed: () async {
                    if (isFlashOn) {
                      cameraController?.setFlashMode(FlashMode.off);
                    } else {
                      cameraController?.setFlashMode(FlashMode.always);
                    }
                    setState(() {
                      isFlashOn = !isFlashOn;
                    });
                  },
                  child: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.grey.shade200,
                  ),
                  // child: Text('${item['name']}')
                ),
              ],
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
            radius: (size.height / 2) - 1),
        const Radius.circular(16)));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(ButtonClipper oldClipper) => false;
}
