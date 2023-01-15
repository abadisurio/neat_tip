import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:neat_tip/screens/result_screen.dart';
import 'package:neat_tip/widgets/camera_scanner.dart';
import 'package:neat_tip/widgets/debit_card.dart';

class SmartCard extends StatefulWidget {
  const SmartCard({Key? key}) : super(key: key);

  @override
  State<SmartCard> createState() => _SmartCardState();
}

class _SmartCardState extends State<SmartCard> {
  bool _isScanning = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: EdgeInsets.only(
        top: _isScanning ? 0 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5)
        ],
      ),
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 500),
      width: _isScanning
          ? MediaQuery.of(context).size.width - 16
          : MediaQuery.of(context).size.width - 48,
      height: _isScanning
          ? MediaQuery.of(context).size.width - 16
          : MediaQuery.of(context).size.width * 0.55,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          fit: StackFit.loose,
          children: [
            // Show the camera feed behind everything
            AnimatedScale(
                scale: _isScanning ? 1.5 : 2.1,
                curve: Curves.easeOutCirc,
                duration: const Duration(milliseconds: 500),
                child: CameraScanner(
                  isScanning: _isScanning,
                  onComplete: (result) async {
                    // log('panggil');
                    setState(() {
                      _isScanning = false;
                    });
                    final navigator = Navigator.of(context);
                    await navigator.push(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ResultScreen(text: result),
                      ),
                    );
                  },
                )),

            AnimatedOpacity(
              curve: Curves.easeOutCirc,
              opacity: _isScanning ? 0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 30.0,
                  sigmaY: 30.0,
                ),
                child: Container(color: Colors.pink.shade600.withOpacity(0.4)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: DebitCard(),
            ),
            SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isScanning = !_isScanning;
                        });
                      },
                      child: Icon(_isScanning
                          ? Icons.keyboard_double_arrow_up_outlined
                          : Icons.fit_screen_outlined),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
