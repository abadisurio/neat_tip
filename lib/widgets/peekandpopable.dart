import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neat_tip/widgets/draggable_card.dart';

class PeekAndPopable extends StatefulWidget {
  final Widget child;
  final Widget? childToPeek;
  final GlobalKey? parentKey;
  final VoidCallback? onDismiss;
  const PeekAndPopable(
      {super.key,
      required this.child,
      this.onDismiss,
      this.parentKey,
      this.childToPeek});

  @override
  State<PeekAndPopable> createState() => _PeekAndPopableState();
}

class _PeekAndPopableState extends State<PeekAndPopable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;
  final stopwatch = Stopwatch();
  bool isLongPressDown = false;
  bool isScaleWidget = false;
  bool isDismissing = false;

  late Timer onHold;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWigetPosition();
    });

    _controller = AnimationController(vsync: this);

    if (widget.onDismiss != null && _animation.value.y > 1.0) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
      onLongPress();
    });
    // Future.delayed(const Duration(milliseconds: 500), () {});
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
    final size = MediaQuery.of(context).size;
    final widgetPosition = getWigetPosition();
    const duration = Duration(milliseconds: 200);
    const curve = Curves.easeInOutCubic;
    final border = BorderRadius.circular(16);
    await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return AnimatedBuilder(
          animation: anim1,
          builder: (BuildContext context, Widget? child) {
            bool isAnimationDone = anim1.value == 1;
            return DraggableCard(
              onState: dragStateChange,
              child: AnimatedContainer(
                padding: EdgeInsets.only(
                  left: isAnimationDone || widgetPosition!.left < 0
                      ? 0
                      : widgetPosition.left,
                  top: isAnimationDone || widgetPosition!.top < 0
                      ? 0
                      : widgetPosition.top,
                  right: isAnimationDone || widgetPosition!.right > size.width
                      ? 0
                      : size.width - widgetPosition.right,
                  bottom:
                      isAnimationDone || widgetPosition!.bottom > size.height
                          ? 0
                          : size.height - widgetPosition.bottom,
                ),
                curve: curve,
                duration: duration,
                height: !isAnimationDone ? size.height : size.height * 3 / 4,
                width: size.width - (isAnimationDone ? 32 : 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: widget.childToPeek != null ? 1 : 0,
                        child: Stack(
                          children: [
                            if (widget.childToPeek != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: widget.childToPeek),
                              ),
                            AnimatedScale(
                              curve: curve,
                              duration: duration,
                              scale:
                                  isAnimationDone && widget.childToPeek != null
                                      ? 1
                                      : 1.05,
                              child: AnimatedOpacity(
                                curve: curve,
                                duration: duration,
                                opacity: isAnimationDone &&
                                        widget.childToPeek != null
                                    ? 0
                                    : 1,
                                child: AnimatedContainer(
                                  curve: curve,
                                  duration: duration,
                                  padding:
                                      EdgeInsets.all(isAnimationDone ? 8 : 0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      widget.child,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        // color: Colors.red,
                        curve: curve,
                        duration: duration,
                        height: isAnimationDone ? 16 : 0,
                      ),
                      AnimatedContainer(
                        curve: curve,
                        height: isAnimationDone ? 100 : 0,
                        width: double.infinity,
                        duration: duration,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: border),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red),
                                        shape: MaterialStateProperty.all(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Text("Hapus"),
                                          Icon(Icons.delete)
                                        ],
                                      )),
                                  TextButton(
                                      onPressed: () {},
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Text("Ubah Rincian"),
                                          Icon(Icons.edit)
                                        ],
                                      )),
                                ]),
                          ),
                        ),
                      ),
                    ]),
              ),
            );
          },
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 7 * anim1.value, sigmaY: 7 * anim1.value),
            child: child);
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: InkWell(
        // onLongPress: onLongPress,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        child: AnimatedScale(
            duration: const Duration(milliseconds: 500),
            curve: Curves.decelerate,
            scale: isScaleWidget ? 1.05 : 1,
            child: widget.child),
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
