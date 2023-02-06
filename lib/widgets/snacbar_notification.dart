import 'dart:developer';

import 'package:flutter/material.dart';

const showDuration = Duration(seconds: 5);

class SnacbarNotification {
  final List<Widget> notificationList = [];
  final content = const SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 50,
      padding: EdgeInsets.all(8),
      duration: showDuration,
      content: SnackBarContent());
  create() {
    return content;
  }
}

class SnackBarContent extends StatefulWidget {
  const SnackBarContent({super.key});

  @override
  State<SnackBarContent> createState() => _SnackBarContentState();
}

class _SnackBarContentState extends State<SnackBarContent>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: showDuration,
    )..addListener(() {
        setState(() {});
      });
    ;
    controller.forward().whenComplete(() => controller.stop());
    // controller.stop();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('message ${controller.value}');
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      curve: Curves.easeOutCirc,
      padding: EdgeInsets.only(
          right: controller.value < 1 ? 0 : screenWidth / 5,
          left: controller.value < 1 ? 0 : screenWidth * 3 / 5),
      duration: const Duration(milliseconds: 1000),
      height: controller.value > 0.01 ? 84 : 0,
      width: screenWidth * (controller.value < 1 ? 1 : 1 / 5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: FittedBox(
          fit: BoxFit.none,
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: screenWidth - 32,
            // height: 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {},
                  // dense: true,
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.motorcycle,
                    ),
                  ),
                  title: const Text('Kurnia Motor'),
                  subtitle: const Text('Dititipkan • Hari ini'),
                  // trailing:
                ),
                LinearProgressIndicator(
                  value: controller.value,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// class SnacbarNotification extends SnackBar {
//   SnacbarNotification({Key? key})
//       : super(key: key, content: SnackBar());

// }