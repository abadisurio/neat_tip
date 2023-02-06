import 'package:flutter/material.dart';

class StateLoading extends StatefulWidget {
  const StateLoading({super.key});

  @override
  State<StateLoading> createState() => _StateLoadingState();
}

class _StateLoadingState extends State<StateLoading>
    with TickerProviderStateMixin {
  late Function argument;
  late AnimationController controller;
  late Animation<double> animation;
  bool isFinished = false;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _runArgument());
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  _runArgument() async {
    await argument();
    // await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isFinished = true;
    });
    Future.delayed(
        const Duration(milliseconds: 800), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    argument = ModalRoute.of(context)!.settings.arguments as Function? ?? () {};
    return WillPopScope(
        onWillPop: () async => true,
        child: Center(
          child: AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInExpo,
            child: isFinished
                ? Icon(
                    Icons.check_box,
                    color: Theme.of(context).indicatorColor,
                    size: 96,
                  )
                : const CircularProgressIndicator(),
          ),
        )
        //
        );
  }
}
