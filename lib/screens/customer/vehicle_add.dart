import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/bloc/vehicle_list.dart';
import 'package:neat_tip/models/vehicle.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class VehicleAdd extends StatefulWidget {
  const VehicleAdd({super.key});

  @override
  State<VehicleAdd> createState() => VehicleAddState();
}

List<Map<String, dynamic>> vehicleFields = [
  {
    "fieldname": "Nama Pemilik *",
    "value": null,
    "type": TextInputType.text,
    "validator": (str) => true,
    "required": true
  },
  {
    "fieldname": "Plat Nomor *",
    "value": null,
    "type": TextInputType.text,
    "validator": (str) => true,
    "required": true,
  },
  {
    "fieldname": "Merek *",
    "value": null,
    "type": TextInputType.text,
    "validator": (str) => true,
    "required": true,
  },
  {
    "fieldname": "Model *",
    "value": null,
    "type": TextInputType.text,
    "validator": (str) => true,
    "required": true,
  },
  {
    "fieldname": "Jumlah Roda",
    "value": null,
    "type": TextInputType.number,
    "validator": (str) {
      return true;
    },
    "required": false,
  },
];

class VehicleAddState extends State<VehicleAdd> {
  Map<String, TextEditingController> vehicleFieldControllers = {};
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollController _listViewController = ScrollController();
  late double screenWidth = MediaQuery.of(context).size.width;
  static const double boxSize = 300;
  static const double contentGap = 16;
  CameraController? cameraController;
  // List<String> imgSrcPhotos = [];
  final List<XFile> _imgFilePhotos = [];
  bool isScreenActive = true;
  bool isCapturing = false;
  bool isFlashOn = false;
  bool isCameraFocus = true;
  final _formKey = GlobalKey<FormState>();

  Future takePicture() async {
    setState(() {
      isCapturing = true;
    });
    if (cameraController != null) {
      final photo = await cameraController!.takePicture();
      setState(() {
        // imgSrcPhotos.add(photo.name);
        _imgFilePhotos.add(photo);
      });
      addPhotoField();
    }
  }

  void addPhotoField() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      _scrollController.scrollTo(
          index: _imgFilePhotos.length,
          curve: Curves.easeOutCirc,
          duration: const Duration(milliseconds: 1500));
    });

    setState(() {
      isCapturing = false;
    });
  }

  removePhoto(int index) {
    setState(() {
      _imgFilePhotos.removeAt(index);
    });
  }

  submitForm() async {
    final vehicleListCubit = context.read<VehicleListCubit>();
    log('heh ');
    String imgSrcNames = '';
    // _imgFilePhotos.map((e) {
    //   log('photo $e');
    // });
    // log('id ${BlocProvider.of<VehicleListCubit>(context).length.toString()}');
    for (var element in _imgFilePhotos) {
      if (imgSrcNames != '') {
        imgSrcNames += ',';
      }
      // log('hehe ');
      // log('${element.path}');
      imgSrcNames += element.name;
    }
    // if (imgSrcNames == '') return;
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      final newVehicle = Vehicle(
          ownerName: vehicleFieldControllers['Nama Pemilik *']!.text,
          createdAt: DateTime.now().toString(),
          id: (BlocProvider.of<VehicleListCubit>(context).length).toString(),
          ownerId: context.read<NeatTipUserCubit>().state!.id,
          imgSrcPhotos: imgSrcNames,
          plate: vehicleFieldControllers['Plat Nomor *']!.text,
          wheel: int.parse(vehicleFieldControllers['Jumlah Roda']!.text),
          brand: vehicleFieldControllers['Merek *']!.text,
          model: vehicleFieldControllers['Model *']!.text);
      // log('message ${vehicleListCubit.state}');
      log('success');
      await Navigator.pushNamed(context, '/state_loading', arguments: () async {
        await vehicleListCubit.addVehicle(newVehicle);
        // await vehicleListCubit.add();
        log('hereeeeee');
      });
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Kendaraan'),
        ),
        body: SafeArea(
            child: NotificationListener(
          onNotification: (t) {
            if (t is ScrollEndNotification) {
              // log('_listViewController ${_listViewController.position.pixels}');
              setState(() {
                if (_listViewController.position.pixels > screenWidth) {
                  isCameraFocus = false;
                } else {
                  isCameraFocus = true;
                }
              });
            }
            return true;
          },
          child: ListView(
            controller: _listViewController,
            children: [
              Stack(
                fit: StackFit.loose,
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
                          scale: 1.5,
                          child: Center(
                            child: CameraCapturer(
                              resolution: ResolutionPreset.medium,
                              controller: (controller) {
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
                    ),
                  SizedBox(
                      height: boxSize,
                      width: screenWidth,
                      child: ScrollablePositionedList.builder(
                        padding: EdgeInsets.only(
                            left: contentGap / 2,
                            right: screenWidth - boxSize - contentGap * 1.5),
                        reverse: true,
                        itemScrollController: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _imgFilePhotos.length + 1,
                        itemBuilder: ((context, index) {
                          if (index == _imgFilePhotos.length) {
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
                                    File(_imgFilePhotos[index].path),
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
                                      },
                                      child: Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.grey.shade200,
                                      ),
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
                    if (cameraController != null && isCameraFocus)
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
                      style:
                          ElevatedButton.styleFrom(shape: const CircleBorder()),
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('(*) Wajib Diisi'),
                      const SizedBox(
                        height: 20,
                      ),
                      ...vehicleFields.map((e) {
                        final controller = vehicleFieldControllers.putIfAbsent(
                            e['fieldname'], () => TextEditingController());
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            keyboardType: e['type'],
                            controller: controller,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Masukkan ${e['fieldname']}',
                                labelText: e['fieldname']),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tidak boleh kosong. Masukkan ${e['fieldname']} Anda!';
                              }
                              if (!e['validator'](value)) {
                                return 'Format ${e['fieldname']} tidak sesuai';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      Center(
                        child: ElevatedButton(
                          onPressed: submitForm,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class ButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.fillType = PathFillType.evenOdd;
    path.addRect(Rect.largest);
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
