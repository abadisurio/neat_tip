import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neat_tip/widgets/draggable_card.dart';

const duration = Duration(milliseconds: 350);
const curve = Curves.easeInOutExpo;
final border = BorderRadius.circular(16);

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
  bool isOpened = false;

  Map<String, dynamic> menuItem = {
    'Hapus': {'icon': Icons.delete, 'color': Colors.red, 'action': () {}},
    'Edit': {'icon': Icons.edit, 'color': null, 'action': () {}},
  };

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
    setState(() {
      isScaleWidget = false;
    });
    await showMoreOptions();
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {});
      });
    }
  }

  void onTapDown(TapDownDetails details) async {
    // stopwatch.start();
    setState(() {
      isScaleWidget = true;
    });

    log('globalPaintBounds ${context.globalPaintBounds}');
    onHold = Timer(const Duration(milliseconds: 300), () {
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
      // isScaleWidget = false;
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

    setState(() {
      isOpened = true;
    });
    await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: duration,
      pageBuilder: (ctx, anim1, anim2) {
        final animController = CurvedAnimation(
            parent: anim1, curve: curve, reverseCurve: Curves.easeInOutCirc);
        return AnimatedBuilder(
          animation: animController,
          builder: (BuildContext context, Widget? child) {
            log('isOpened0 $isOpened');
            if (anim1.value == 1) {
              isOpened = false;
            }
            final dx = ((widgetPosition!.center.dx) * 2 - size.width) /
                (size.width - (widgetPosition.width));
            final dy = ((widgetPosition.center.dy) * 2 - size.height) /
                (size.height - (widgetPosition.height));
            return DraggableCard(
              aligmentOverride: Alignment(
                  (1 - animController.value) * (dx.isNaN ? 0 : dx),
                  (1 - animController.value) * (dy.isNaN ? 0 : dy)),
              onState: dragStateChange,
              child: Container(
                margin: EdgeInsets.only(top: animController.value * 48),
                height: 124 * animController.value +
                    (widget.childToPeek != null
                        ? widgetPosition.height * (1 - animController.value) +
                            size.height * 0.60 * animController.value
                        : widgetPosition.height),
                width: ((1 - animController.value) * widgetPosition.width +
                    (size.width - 64) * animController.value),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: widget.childToPeek != null ? 1 : 0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (widget.childToPeek != null)
                              Opacity(
                                opacity: animController.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: widget.childToPeek),
                                ),
                              ),
                            Transform.scale(
                              scale: 1.05 -
                                  (!isOpened
                                      ? 0.05
                                      : (animController.value) * 0.05),
                              child: Opacity(
                                opacity: widget.childToPeek == null
                                    ? 1
                                    : (1 - animController.value),
                                child: Container(
                                  padding:
                                      EdgeInsets.all(animController.value * 4),
                                  decoration: BoxDecoration(
                                    color: widget.childToPeek != null
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
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: animController.value * 16,
                      ),
                      SizedBox(
                        height:
                            animController.value * menuItem.entries.length * 50,
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Opacity(
                            opacity: animController.value,
                            child: Container(
                                width: 250,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: border),
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: menuItem.entries.length,
                                  padding: const EdgeInsets.all(0.0),
                                  itemBuilder: (context, index) {
                                    log('index $index');
                                    return TextButton(
                                        style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all(menuItem
                                                      .entries
                                                      .elementAt(index)
                                                      .value['color'] ??
                                                  Colors.blue),
                                          shape: MaterialStateProperty.all(
                                            const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.zero),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(menuItem.entries
                                                .elementAt(index)
                                                .key),
                                            Icon(menuItem.entries
                                                .elementAt(index)
                                                .value['icon'])
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
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.decelerate,
            scale: isScaleWidget ? 1.05 : 1,
            child: AnimatedOpacity(
                duration: const Duration(milliseconds: 50),
                curve: Curves.decelerate,
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
