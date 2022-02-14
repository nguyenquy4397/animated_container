import 'dart:math';

import 'package:animated_container/confetti.dart';
import 'package:flutter/material.dart';

/// This widget is a widget with confetti effect behind or front of child
/// widget and effect align in center
/// can control with controller
class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget(
      {Key? key,
      required this.child,
      required this.confettiController,
      this.isBackground = false})
      : super(key: key);
  final Widget child;
  final ConfettiController confettiController;

  /// if true, confetti go to behind of child
  /// if false, confetti go to front of child
  /// default is false
  final bool isBackground;
  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!widget.isBackground)
          Align(
            child: widget.child,
            alignment: Alignment.center,
          ),
        ConfettiEffect(
          confettiController: widget.confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          blastDirection: -pi / 2,
          maxBlastForce: 120,
          minBlastForce: 10,
          numberOfParticles: 100,
          gravity: 0.3,
          createParticlePaths: const [ConfettiUtils.drawStar],
        ),
        if (widget.isBackground)
          Align(
            child: widget.child,
            alignment: Alignment.center,
          ),
      ],
    );
  }
}
