import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neat_tip/widgets/draggable_card.dart';

const peekDuration = Duration(milliseconds: 350);
const curve = Curves.easeInOutExpo;
final border = BorderRadius.circular(16);

class PeekAndPopable extends StatefulWidget {
  final EdgeInsets? peekPadding;
  final Function? onDidPop;
  final Widget child;
  final List<Map<String, dynamic>> actions;
  final Widget? childToPeek;
  const PeekAndPopable(
      {super.key,
      required this.child,
      this.childToPeek,
      this.peekPadding,
      required this.actions,
      this.onDidPop});

  @override
  State<PeekAndPopable> createState() => _PeekAndPopableState();
}

class _PeekAndPopableState extends State<PeekAndPopable>
    with SingleTickerProviderStateMixin {
  // late AnimationController innerController;
  // late Animation<Alignment> _animation;
  final stopwatch = Stopwatch();
  bool isScaleWidget = false;
  bool isDismissing = false;
  bool isOpened = false;

  late Timer onHold;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWigetPosition();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onLongPress() async {
    showMoreOptions();
    setState(() {
      isScaleWidget = false;
    });
  }

  void onTapDown(TapDownDetails details) async {
    // stopwatch.start();
    setState(() {
      isScaleWidget = true;
    });

    log('globalPaintBounds ${context.globalPaintBounds}');
    onHold = Timer(const Duration(milliseconds: 500), () {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => HapticFeedback.lightImpact(),
      );
      HapticFeedback.lightImpact();
      onLongPress();
    });
    // Future.delayed(const Duration(milliseconds: 300), () {});
  }

  void onTapUp(TapUpDetails details) {
    log('up ${onHold.isActive}');
    onHold.cancel();
    setState(() {
      isScaleWidget = false;
    });
  }

  void dragStateChange(state) {
    switch (state) {
      case DragState.dismiss:
        Navigator.pop(context);
        break;
      default:
    }
  }

  Rect? getWigetPosition() {
    return context.globalPaintBounds;
  }

  Future<void> showMoreOptions() async {
    setState(() {
      isOpened = true;
    });

    await Navigator.push(
        context,
        PageRouteBuilder(
            reverseTransitionDuration: peekDuration,
            transitionDuration: peekDuration,
            transitionsBuilder: (ctx, anim1, anim2, child) {
              return BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 7 * anim1.value, sigmaY: 7 * anim1.value),
                  child: child);
            },
            fullscreenDialog: true,
            opaque: false,
            barrierDismissible: true,
            barrierLabel: '',
            barrierColor: Colors.black38,
            pageBuilder: (context, anim1, anim2) => PeekPage(
                  actions: widget.actions,
                  peekPadding: widget.peekPadding,
                  childToPeek: widget.childToPeek,
                  transitionAnimation: anim1,
                  childPosition: getWigetPosition()!,
                  child: widget.child,
                )));
    if (mounted) {
      // log('mounted ${mounted}');
      Future.delayed(const Duration(milliseconds: 250), () {
        setState(() {
          isOpened = false;
        });
      });
    }
    if (widget.onDidPop != null) {
      widget.onDidPop!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('isOpened $isOpened');

    return ClipRect(
      child: InkWell(
        // onLongPress: onLongPress,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        child: AnimatedScale(
            duration: const Duration(milliseconds: 500),
            curve: Curves.decelerate,
            scale: isScaleWidget ? 1.05 : 1,
            child: AnimatedOpacity(
                curve: curve,
                duration: const Duration(milliseconds: 50),
                opacity: isOpened ? 0 : 1,
                child: widget.child)),
      ),
    );
  }
}

extension GlobalPaintBounds on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

class PeekPage extends StatefulWidget {
  final Animation<double> transitionAnimation;
  final Widget? childToPeek;
  final Widget child;
  final Rect childPosition;
  final EdgeInsets? peekPadding;
  final List<Map<String, dynamic>> actions;
  const PeekPage(
      {super.key,
      required this.transitionAnimation,
      required this.childPosition,
      this.childToPeek,
      required this.child,
      this.peekPadding,
      required this.actions});

  @override
  State<PeekPage> createState() => _PeekPageState();
}

class _PeekPageState extends State<PeekPage> with TickerProviderStateMixin {
  late AnimationController controller;
  late List<Map<String, dynamic>> menuItem;
  double offsetY = 0;
  bool isOpened = false;
  bool isOpened2 = false;
  double cardScale = 1;

  @override
  void initState() {
    menuItem = widget.actions;
    controller = AnimationController(vsync: this, duration: peekDuration);
    controller.value = 0;
    Future.delayed(peekDuration, () {
      setState(() {
        isOpened = true;
        isOpened2 = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final childToPeek = widget.childToPeek;
    final anim1 = widget.transitionAnimation;
    final childPosition = widget.childPosition;
    final innerController = CurvedAnimation(parent: anim1, curve: curve);
    // log('message $childPosition');
    return WillPopScope(
      onWillPop: () {
        setState(() {
          isOpened = false;
          // cardScale = 1;
        });
        // Navigator.pop(context);
        return Future.value(true);
      },
      child: AnimatedBuilder(
        animation: innerController,
        builder: (BuildContext context, Widget? child) {
          // log('innerController ${innerController.value}');
          // log('isCollapsed ${offsetY > 0.5 || !isOpened}');
          // log('cardScale ${1 + ((1 - innerController.value) * 0.05)}');
          // log('isOpened2 ${widget.peekPadding!.top + widget.peekPadding!.bottom}');
          // log('isOpened3 ${size.height * 0.4}');
          // log('isOpened3 ${const ViewConfiguration().devicePixelRatio}');
          return DraggableCard(
            onDragChange: (p0) {
              // log('detail ${p0.y}');
              if (p0.y < 0) return;
              setState(() {
                offsetY = p0.y;
                cardScale = (1 - p0.y / 2.5);
              });
            },
            onDragEnd: (p0) {
              // log('message ${p0}');
              setState(() {
                cardScale = 1;
              });
              if (p0.velocity.pixelsPerSecond.dy > 1) {
                Navigator.maybePop(context);
              } else {
                setState(() {
                  offsetY = 0;
                });
              }
            },
            // onState: dragStateChange,
            child: Container(
              // color: Colors.red,
              padding: EdgeInsets.only(
                left: childPosition.left > 0
                    ? childPosition.left * (1 - innerController.value)
                    : 0,
                top: childPosition.top > 0
                    ? childPosition.top * (1 - innerController.value)
                    : 0,
                right: childPosition.right < size.width
                    ? (size.width - childPosition.right) *
                        (1 - innerController.value)
                    : 0,
                bottom: childPosition.bottom < size.height
                    ? (size.height - childPosition.bottom) *
                        (1 - innerController.value)
                    : 0,
              ),
              height: size.height +
                  innerController.value *
                      ((menuItem.length * 50 + 24) -
                          ((widget.childToPeek != null
                              ? widget.peekPadding != null
                                  ? (widget.peekPadding!.top +
                                      widget.peekPadding!.bottom)
                                  : size.height * 0.4
                              : childPosition.top +
                                  (size.height - childPosition.bottom)))),
              width: size.width * ((1 - innerController.value) + 9) / 10,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: childToPeek != null ? 1 : 0,
                      child: AnimatedScale(
                        alignment: isOpened2
                            ? Alignment.bottomCenter
                            : Alignment.center,
                        curve: isOpened ? Curves.easeOutCubic : curve,
                        duration: cardScale < 1 || !isOpened2
                            ? const Duration(milliseconds: 0)
                            : peekDuration,
                        scale: cardScale +
                            (isOpened2
                                ? 0
                                : (1 - innerController.value) * 0.05),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (childToPeek != null)
                              Opacity(
                                opacity: innerController.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: childToPeek),
                                ),
                              ),
                            Opacity(
                              opacity: childToPeek != null
                                  ? (1 - innerController.value)
                                  : 1,
                              child: Container(
                                padding:
                                    EdgeInsets.all(innerController.value * 4),
                                decoration: BoxDecoration(
                                  color: childToPeek != null
                                      ? null
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    widget.child,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: innerController.value * 16,
                    ),
                    AnimatedContainer(
                      // curve: isOpened ? Curves.easeOutCubic : curve,
                      curve: isOpened ? Curves.easeOutCubic : curve,
                      duration: isOpened
                          ? peekDuration
                          : const Duration(milliseconds: 0),
                      height: offsetY > 0.1 * menuItem.length
                          ? 0
                          : innerController.value * menuItem.length * 50,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: AnimatedOpacity(
                          curve: isOpened ? Curves.easeOutCubic : curve,
                          duration: isOpened
                              ? peekDuration
                              : const Duration(milliseconds: 0),
                          opacity: offsetY > 0.3 * menuItem.length
                              ? 0
                              : innerController.value,
                          child: Container(
                              width: 250,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: border),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: menuItem.length,
                                padding: const EdgeInsets.all(0.0),
                                itemBuilder: (context, index) {
                                  return TextButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(Color(
                                                menuItem.elementAt(
                                                        index)['color'] ??
                                                    0xFF0000FF)),
                                        shape: MaterialStateProperty.all(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero),
                                        ),
                                      ),
                                      onPressed: () {
                                        menuItem.elementAt(index)['onTap']();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(menuItem
                                              .elementAt(index)['name']),
                                          Icon(
                                              menuItem.elementAt(index)['icon'])
                                        ],
                                      ));
                                },
                              )),
                        ),
                      ),
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }
}
