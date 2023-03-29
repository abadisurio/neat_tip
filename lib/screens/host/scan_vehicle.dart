import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/utils/constants.dart';
import 'package:neat_tip/utils/get_input_image.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';
import 'package:path_provider/path_provider.dart';

class ScanVehicle extends StatefulWidget {
  const ScanVehicle({Key? key}) : super(key: key);

  @override
  State<ScanVehicle> createState() => _ScanVehicleState();
}

class _ScanVehicleState extends State<ScanVehicle> with RouteAware {
  CameraController? _cameraController;
  bool _isScanning = true;
  bool isScreenActive = false;
  bool isBatchScanning = false;
  String _lastDetectedPlate = "";
  bool _isDetecting = false;
  final Map<String, String> _listDetectedPlate = {};
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

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

  _onControllerMounted(controller) {
    setState(() {
      _cameraController = controller;
    });
  }

  _confirmScan() {
    Navigator.pushNamed(context, '/confirm_scan_vehicle',
        arguments: _listDetectedPlate);
  }

  _correctionScan() async {
    final newPlate = await showDialog<String?>(
        context: context,
        builder: ((context) {
          final controller = TextEditingController(text: _lastDetectedPlate);
          return AlertDialog(
            title: const Text('Tambah Kendaraan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Silakan isi nomor plat kendaraan\n'),
                TextFormField(
                  controller: controller,
                  validator: (value) {
                    log('value $value');
                    if (value == null || !regexPlate.hasMatch(value)) {
                      return 'Plat nomor tidak sesuai format';
                    }
                    return null;
                  },
                  autofocus: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan plat nomor',
                      labelText: 'Plat nomor'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batalkan'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Lanjutkan'),
              ),
            ],
          );
        }));
    if (newPlate != null) {
      log('newPlate $newPlate');
      final String imgSrc = _listDetectedPlate[_lastDetectedPlate]!;
      _listDetectedPlate.addAll({newPlate: imgSrc});
      _listDetectedPlate.remove(_lastDetectedPlate);
      setState(() {
        _lastDetectedPlate = newPlate;
      });
      // Navigator.pushNamed(context, '/confirm_scan_vehicle',
      //     arguments: {"scannedVehicleList": _listDetectedPlate});
    }
  }

  _startScanning() {
    setState(() {
      _isScanning = true;
    });
    _cameraController?.setFlashMode(FlashMode.off);
    _cameraController?.startImageStream((image) {
      // log('hehe');
      if (_lastDetectedPlate != "") {
        setState(() {
          _lastDetectedPlate = "";
        });
        return;
      }
      if (!_isScanning) return;
      if (!_isDetecting) _processCameraImage(image);
    });
  }

  Future<void> _stopScanning() async {
    log('_lastDetectedPlate $_lastDetectedPlate');
    if (_cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
    setState(() {
      _isScanning = false;
    });
    // textRecognizer.close();
    // log('_cameraController!.value.isStreamingImages ${_cameraController!.value.isStreamingImages}');
    // if (_cameraController!.value.isStreamingImages) {
    //   log('berenti');
    //   await _cameraController?.stopImageStream();
    // }
  }

  Future<File> _takePicture() async {
    Directory tempDir = await getTemporaryDirectory();
    final XFile photo = await _cameraController!.takePicture();
    // log('photo ${photo.path} ');

    log('photo ${photo.name}');
    final filePhoto = await File(
            '${tempDir.path}${Platform.isIOS ? '/camera/pictures' : ''}/${photo.name}')
        .create();
    final photoBytes = await photo.readAsBytes();
    await filePhoto.writeAsBytes(photoBytes.toList());
    return filePhoto;
  }

  void _itemDetected(String plateNumber) async {
    await _stopScanning();
    final imgFile = await _takePicture();
    setState(() {
      _lastDetectedPlate = plateNumber;
      _listDetectedPlate.addAll({plateNumber: imgFile.path});
    });
  }

  void _processCameraImage(CameraImage image) async {
    _isDetecting = true;

    InputImage inputImage = getInputImage(image);
    try {
      final RecognizedText recognisedText = await textRecognizer
          .processImage(inputImage)
          .onError((error, stackTrace) {
        log('error $error');
        return RecognizedText(text: 'text', blocks: []);
      });
      if (recognisedText.blocks.isNotEmpty) {
        for (TextBlock block in recognisedText.blocks) {
          log('block.text ${block.text}');
          if (regexPlate.hasMatch(block.text)) {
            _itemDetected(block.text);
          }
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
      textRecognizer.close();
      _isDetecting = false;
    } catch (e) {
      log('error $e');
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() {
        isScreenActive = true;
      });
    });
    _startScanning();

    // Future.delayed(const Duration(seconds: 3), () {
    //   _itemDetected('B 3149 EGR');
    // });
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_cameraController != null) {
    //   _startScanning();
    // }
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Container(
            // color: Colors.grey.shade900,
            padding: const EdgeInsets.all(16),
            // curve: Curves.easeOutCirc,
            // duration: const Duration(milliseconds: 500),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * (3 / 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                color: Colors.grey.shade900,
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    if (isScreenActive)
                      AnimatedOpacity(
                        opacity: _isScanning ? 1 : 0.1,
                        curve: Curves.easeOutCirc,
                        duration: const Duration(milliseconds: 500),
                        child: Transform.scale(
                          scale: 1.4,
                          child: CameraCapturer(
                            resolution: ResolutionPreset.low,
                            controller: (controller) {
                              setState(() {
                                _cameraController = controller;
                              });
                              _startScanning();
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
                                  Shadow(color: Colors.black, blurRadius: 3)
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
                                'Kendaraan Terdeteksi',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(color: Colors.white),
                              ),
                              if (!_isScanning && _lastDetectedPlate == '')
                                Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    Text(
                                      'Tahan',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(color: Colors.white),
                                    )
                                  ],
                                )
                              else if (_listDetectedPlate.isNotEmpty)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(File(
                                            _listDetectedPlate
                                                .entries.last.value)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 0, 8, 4),
                                            child: Text(
                                                _listDetectedPlate
                                                    .entries.last.key,
                                                style: TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.grey.shade900)),
                                          ),
                                          if (_listDetectedPlate.length > 1)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 16),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 0, 8, 8),
                                              decoration: BoxDecoration(
                                                  boxShadow: _listDetectedPlate
                                                              .length <
                                                          2
                                                      ? null
                                                      : [
                                                          const BoxShadow(
                                                              spreadRadius: -2,
                                                              color:
                                                                  Colors.white,
                                                              offset: Offset(
                                                                  -8, -8)),
                                                          BoxShadow(
                                                              spreadRadius: -2,
                                                              color: Colors.grey
                                                                  .shade900,
                                                              offset:
                                                                  const Offset(
                                                                      -5, -5)),
                                                        ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Text(
                                                '+${_listDetectedPlate.length - 1}',
                                                style: TextStyle(
                                                    color: Colors.grey.shade900,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                            icon: const Icon(Icons.add),
                                            onPressed: _startScanning,
                                            label: const Text('Tambah Lagi ')),
                                        const SizedBox(width: 16),
                                        ElevatedButton.icon(
                                            icon: const Icon(Icons.edit),
                                            onPressed: _correctionScan,
                                            label: const Text('Koreksi')),
                                      ],
                                    )
                                  ],
                                ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kendaraan Terdeteksi',
                  style: Theme.of(context).textTheme.headline6,
                ),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _listDetectedPlate.isEmpty ? null : _confirmScan,
                    child: const Text('Proses'))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  crossAxisCount: 2,
                ),
                itemCount: _listDetectedPlate.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_listDetectedPlate.entries
                                .elementAt(index)
                                .value),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Text(
                        _listDetectedPlate.entries.elementAt(index).key,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
