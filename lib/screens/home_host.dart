import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neat_tip/widgets/camera_capturer.dart';

class HomeHost extends StatefulWidget {
  const HomeHost({Key? key}) : super(key: key);

  @override
  State<HomeHost> createState() => _HomeHostState();
}

class _HomeHostState extends State<HomeHost> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    // initializeDateFormatting('id_ID', '');

    int storedVehicle = 25;
    int capacity = 90;

    const thinStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w300);

    return SafeArea(
      child: DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                tabController.animateTo(0);
              },
              child: const Text('Pindai motor'),
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              if (mounted)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // margin: const EdgeInsets.only(left: contentGap),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade50)),
                    width: 300,
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Transform.scale(
                        scale: 1.5,
                        child: Center(
                          child: CameraCapturer(
                            resolution: ResolutionPreset.medium,
                            controller: (controller) {
                              controller.setFlashMode(FlashMode.off);
                              // setState(() {
                              //   cameraController = controller;
                              // });
                              // }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Builder(builder: (context) {
                return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            foregroundImage: NetworkImage(
                                FirebaseAuth.instance.currentUser?.photoURL ??
                                    ''),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Neat Tip',
                            style: thinStyle,
                          ),
                          Text(
                            'Kurnia Motor',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 2.0, // gap between adjacent chips
                          runSpacing: 2.0, // gap between lines
                          children: [
                            ...List.generate(
                                (156 * storedVehicle / capacity).ceil(),
                                ((index) {
                              return const Icon(Icons.play_arrow);
                            })),
                            ...List.generate(
                                (156 * (1 - storedVehicle / capacity)).floor(),
                                ((index) {
                              return const Icon(Icons.play_arrow_outlined);
                            })),
                          ]),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              return Text(
                                DateFormat(
                                        'EEEE,\nD MMM yyyy\nhh:mm:ss', 'id_ID')
                                    .format(DateTime.now()),
                                style: thinStyle,
                              );
                            },
                          ),
                          RichText(
                            textAlign: TextAlign.end,
                            text: TextSpan(
                              text: '$storedVehicle',
                              style: TextStyle(
                                  fontSize: 60,
                                  color: Colors.grey.shade900,
                                  fontWeight: FontWeight.w300),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '/$capacity\n',
                                  style: TextStyle(
                                      fontSize: 34,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w200),
                                ),
                                TextSpan(
                                  text: 'Kendaraan dititip',
                                  style: thinStyle.copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          // Text(
                          //   'Kurnia Motor',
                          //   style: Theme.of(context).textTheme.headline6,
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ]);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
