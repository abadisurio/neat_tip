import 'package:flutter/material.dart';

class LoadingWindow extends StatelessWidget {
  const LoadingWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.blue.shade900,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Menyiapkan sesuatu\nuntuk Anda\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator()
            ]),
      ),
    );
  }
}
