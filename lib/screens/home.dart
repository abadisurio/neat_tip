import 'package:flutter/material.dart';
import 'package:neat_tip/widgets/dashboard_menu.dart';
import 'package:neat_tip/widgets/smart_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  // We should stop the camera once this widget is disposed
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  children: const [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 30),
                        child: DashboardMenu(),
                      ),
                    ),
                    // SmartCard()
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
