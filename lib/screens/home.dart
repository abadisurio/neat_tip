import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/route_observer.dart';
import 'package:neat_tip/widgets/dashboard_menu.dart';
import 'package:neat_tip/widgets/smart_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  bool isScreenActive = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeObserver =
        BlocProvider.of<RouteObserverCubit>(context).routeObserver;
    log('routeObserver $routeObserver');
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didPushNext() {
    log('didPushNext');
    setState(() {
      isScreenActive = false;
    });
    // TODO: implement didPushNext
    super.didPushNext();
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    log('didPopNext');
    setState(() {
      isScreenActive = true;
    });
    super.didPopNext();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    log('deact');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // bool isScreenActive = true;
    log('isScreenActive $isScreenActive');
    // final routeNow = ModalRoute.of(context)?.settings.name;
    // Navigator.of(context).
    // log('$routeNow');
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                // color: Colors.red,
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 30),
                        child: DashboardMenu(),
                      ),
                    ),
                    if (isScreenActive) const SmartCard()
                  ],
                ),
              ),
              Text('text ' * 1000)
            ],
          ),
        ),
      ),
    );
  }
}
