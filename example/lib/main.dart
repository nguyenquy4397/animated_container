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
  final _controllerCenter =
      ConfettiController(duration: const Duration(seconds: 1));
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test'),
          leading: (_index == 1)
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _index = 0;
                    });
                  },
                  icon: const Icon(Icons.arrow_back))
              : null,
        ),
        body: ConfettiWidget(
          child: Container(
            child: TextButton(
              child: const Text('bruhhhh'),
              onPressed: () {
                _controllerCenter.play();
              },
            ),
            color: Colors.blueGrey,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          confettiController: _controllerCenter,
          isBackground: false,
        ),
      ),
    );
  }
}
