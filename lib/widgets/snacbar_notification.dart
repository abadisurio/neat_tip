import 'dart:developer';

import 'package:flutter/material.dart';

const showDuration = Duration(seconds: 5);

class SnacbarNotification {
  final Widget? content;
  final Icon? icon;
  SnacbarNotification({this.content, this.icon});
  create() {
    return SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 50,
        padding: const EdgeInsets.all(8),
        duration: showDuration,
        content: SnackBarContent(
          content: content,
          icon: icon,
        ));
  }
}

class SnackBarContent extends StatefulWidget {
  final Widget? content;
  final Icon? icon;
  const SnackBarContent({super.key, this.content, this.icon});

  // ListTile(
  //                   onTap: () {},
  //                   // dense: true,
  //                   leading: notificationIcon,
  //                   title: const Text('Kurnia Motor'),
  //                   subtitle: const Text('Dititipkan • Hari ini'),
  //                   // trailing:
  //                 ),

  @override
  State<SnackBarContent> createState() => _SnackBarContentState();
}

class _SnackBarContentState extends State<SnackBarContent>
    with TickerProviderStateMixin {
  late Widget icon;
  late AnimationController controller;

  @override
  void initState() {
    icon = CircleAvatar(
      child: widget.icon,
    );
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
    // log('message ${controller.value}');
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      curve: Curves.easeOutCirc,
      padding: EdgeInsets.only(
          right: controller.value < 1 ? 0 : screenWidth / 5,
          left: controller.value < 1 ? 0 : screenWidth * 3 / 5),
      duration: const Duration(milliseconds: 500),
      height: controller.value > 0.05 ? 84 : 0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: FittedBox(
          fit: BoxFit.none,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: screenWidth - 16,
            // height: 90,
            child: AnimatedCrossFade(
              crossFadeState: controller.value < 1
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              secondChild: Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: icon,
              )),
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.content ?? const SizedBox.shrink(),
                  LinearProgressIndicator(
                    value: controller.value,
                    backgroundColor: Theme.of(context).canvasColor,
                    color: Theme.of(context).primaryColor,
                  )
                ],
              ),
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