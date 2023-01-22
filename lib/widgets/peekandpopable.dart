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

  Rect? getWigetPosition() {
    return context.globalPaintBounds;
  }

  Future<void> showMoreOptions() async {
    final size = MediaQuery.of(context).size;
    final widgetPosition = getWigetPosition();
    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeOutCirc;
    final border = BorderRadius.circular(16);
    await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return DraggableCard(
            child: FutureBuilder(
                future: Future.delayed(const Duration(milliseconds: 200)),
                builder: (context, snapshot) {
                  final isAnimationDone =
                      snapshot.connectionState == ConnectionState.done;
                  return SizedBox(
                    width: size.width - (isAnimationDone ? 32 : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widgetPosition!.height > 0)
                          AnimatedContainer(
                            height: isAnimationDone ? 0 : widgetPosition.top,
                            curve: curve,
                            duration: duration,
                          ),
                        AnimatedSize(
                          curve: curve,
                          duration: duration,
                          child: SizedBox(
                            width: size.width - (isAnimationDone ? 32 : 0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (widget.childToPeek != null)
                                  ClipRRect(
                                    borderRadius: border,
                                    child: AnimatedSize(
                                      curve: curve,
                                      duration: duration,
                                      child: SizedBox(
                                        height: isAnimationDone ? null : 0,
                                        child: widget.childToPeek,
                                      ),
                                    ),
                                  ),
                                AnimatedOpacity(
                                  curve: curve,
                                  opacity: isAnimationDone &&
                                          widget.childToPeek != null
                                      ? 0
                                      : 1,
                                  duration: duration,
                                  child: Transform.scale(
                                      scale: 1.05, child: widget.child),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: duration,
                          height: isAnimationDone ? 16 : 0,
                        ),
                        AnimatedSize(
                          curve: curve,
                          duration: duration,
                          child: Container(
                            // margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: border),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: !isAnimationDone
                                    ? []
                                    : [
                                        TextButton.icon(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {},
                                            label:
                                                const Text("Hapus Kendaraan")),
                                        TextButton.icon(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {},
                                            label: const Text("Ubah Rincian")),
                                      ]),
                          ),
                        ),
                        if (widgetPosition.bottom < size.height)
                          AnimatedContainer(
                            height: isAnimationDone
                                ? 0
                                : size.height - widgetPosition.bottom,
                            curve: curve,
                            duration: duration,
                          ),
                      ],
                    ),
                  );
                }));
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 7 * anim1.value, sigmaY: 7 * anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
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
            curve: Curves.easeIn,
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
