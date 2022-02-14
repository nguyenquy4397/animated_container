import 'dart:math';

import 'package:animated_container/confetti.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controllerTopLeft = ConfettiController();
  final _controllerTopCenter = ConfettiController();
  final _controllerTopRight = ConfettiController();
  final _controllerCenter = ConfettiController();
  final _controllerLimitedSize = ConfettiController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ConfettiWidget(
              confettiController: _controllerTopLeft,
              alignment: Alignment.topLeft,
              blastDirection: pi / 4,
              displayTarget: true,
            ),
            ConfettiWidget(
              confettiController: _controllerTopCenter,
              alignment: Alignment.topCenter,
              blastDirection: pi / 2,
              displayTarget: true,
              numberOfParticles: 50,
              createParticlePaths: const [ConfettiUtils.drawStar],
            ),
            ConfettiWidget(
              confettiController: _controllerTopRight,
              alignment: Alignment.topRight,
              blastDirection: 3 * pi / 4,
              displayTarget: true,
              createParticlePaths: const [ConfettiUtils.drawStar],
            ),
            ConfettiWidget(
              confettiController: _controllerTopRight,
              alignment: Alignment.topRight,
              blastDirection: 3 * pi / 4,
              displayTarget: true,
              createParticlePaths: const [ConfettiUtils.drawStar],
            ),
            ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality.explosive,
              displayTarget: true,
              shouldLoop: true,
              createParticlePaths: const [ConfettiUtils.drawStar],
            ),
            Positioned(
              bottom: 50,
              left: 130,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blueGrey,
                child: Stack(
                  children: [
                    ConfettiWidget(
                      alignment: Alignment.center,
                      confettiController: _controllerLimitedSize,
                      displayTarget: true,
                      canvas: const Size(200, 200),
                      blastDirectionality: BlastDirectionality.explosive,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Row(
          children: [
            TextButton(
              onPressed: () {
                if (_controllerTopLeft.state ==
                    ConfettiControllerState.stopped) {
                  _controllerTopLeft.play();
                } else {
                  _controllerTopLeft.stop();
                }
              },
              child: const Text('top left'),
            ),
            TextButton(
              onPressed: () {
                if (_controllerTopCenter.state ==
                    ConfettiControllerState.stopped) {
                  _controllerTopCenter.play();
                } else {
                  _controllerTopCenter.stop();
                }
              },
              child: const Text('top center'),
            ),
            TextButton(
              onPressed: () {
                if (_controllerTopRight.state ==
                    ConfettiControllerState.stopped) {
                  _controllerTopRight.play();
                } else {
                  _controllerTopRight.stop();
                }
              },
              child: const Text('top right'),
            ),
            TextButton(
              onPressed: () {
                if (_controllerCenter.state ==
                    ConfettiControllerState.stopped) {
                  _controllerCenter.play();
                } else {
                  _controllerCenter.stop();
                }
              },
              child: const Text('center'),
            ),
            TextButton(
              onPressed: () {
                if (_controllerLimitedSize.state ==
                    ConfettiControllerState.stopped) {
                  _controllerLimitedSize.play();
                } else {
                  _controllerLimitedSize.stop();
                }
              },
              child: const Text('limited size'),
            ),
          ],
        ),
      ),
    );
  }
}
