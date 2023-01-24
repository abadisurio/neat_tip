import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

enum DragState {
  willDismiss,
  willCancelDismiss,
  idle,
  dismiss,
}

/// A draggable card that moves back to [Alignment.center] when it's
/// released.
class DraggableCard extends StatefulWidget {
  final VoidCallback? onDismiss;
  final Alignment? aligmentOverride;
  final Function(DragState)? onState;
  final Function(Alignment)? onAlignmentChange;
  const DraggableCard(
      {required this.child,
      super.key,
      this.onDismiss,
      this.onState,
      this.onAlignmentChange,
      this.aligmentOverride});

  final Widget child;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_animation].
  Alignment _dragAlignment = Alignment.center;
  bool isChangingState = false;
  DragState dragState = DragState.idle;
  Offset yPosition = const Offset(0, 0);

  late Animation<Alignment> _animation;

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: dragState == DragState.dismiss
            ? widget.aligmentOverride ?? Alignment.center
            : Alignment.center,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });

      // isChangingState = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        // details.po
        setState(() {
          yPosition = details.globalPosition;
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
        if (widget.onAlignmentChange != null) {
          widget.onAlignmentChange!(_dragAlignment);
        }
      },
      onPanStart: (details) {},
      onPanEnd: (details) {
        log('details $details');
        _runAnimation(details.velocity.pixelsPerSecond, size);
        if (details.velocity.pixelsPerSecond.dy > 1000) {
          if (widget.onState != null) {
            setState(() {
              dragState = DragState.dismiss;
            });
            widget.onState!(DragState.dismiss);
          }
        }
      },
      child: Align(
        alignment:
            _dragAlignment + (widget.aligmentOverride ?? const Alignment(0, 0)),
        child: Material(
          type: MaterialType.transparency,
          child: widget.child,
        ),
      ),
    );
  }
}
