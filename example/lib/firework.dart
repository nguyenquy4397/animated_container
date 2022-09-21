import 'dart:math';

import 'package:animated_container/confetti.dart';
import 'package:flutter/material.dart';

class Firework extends StatefulWidget {
  const Firework({Key? key}) : super(key: key);

  @override
  _FireworkState createState() => _FireworkState();
}

class _FireworkState extends State<Firework> {
  final _controller = ConfettiController(duration: const Duration(seconds: 5));
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextButton(
          onPressed: () {
            _controller.play();
          },
          child: const Text('fire!'),
        ),
        ConfettiEffect(
          alignment: Alignment.center,
          confettiController: _controller,
          displayTarget: false,
          blastDirectionality: BlastDirectionality.explosive,
          blastDirection: 2 * pi,
          minimumSize: const Size(5, 2),
          maximumSize: const Size(5, 2),
          minBlastForce: 0.001,
          maxBlastForce: 0.0011,
          gravity: 0.1,
          particleDrag: 0.1,
          numberOfParticles: 35,
          emissionFrequency: 0.00000001,
          shouldLoop: false,
        ),
      ],
    );
  }
}
