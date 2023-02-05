import 'package:flutter/material.dart';

class StateLoading extends StatelessWidget {
  const StateLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)!.settings.arguments! as Function();
    return WillPopScope(
        onWillPop: () async => false,
        // child: SizedBox(),
        child: FutureBuilder(
            future: argument(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Navigator.pop(context);
              }
              return const Center(child: CircularProgressIndicator());
            })
        //
        );
  }
}
