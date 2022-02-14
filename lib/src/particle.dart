import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vmath;

import 'enums/blast_directionality.dart';
import 'utils.dart';

enum ParticleSystemStatus {
  started,
  finished,
  stopped,
}

class ParticleSystem extends ChangeNotifier {
  ParticleSystem({
    required double emissionFrequency,
    required int numberOfParticles,
    required double maxBlastForce,
    required double minBlastForce,
    required double blastDirection,
    required BlastDirectionality blastDirectionality,
    required List<Color>? colors,
    required Size minimumSize,
    required Size maximumSize,
    required double particleDrag,
    required double gravity,
    List<Path Function(Size size)>? createParticlePaths,
    required AlignmentGeometry emitterAlignment,
  })  : assert(maxBlastForce > 0 &&
            minBlastForce > 0 &&
            emissionFrequency >= 0 &&
            emissionFrequency <= 1 &&
            numberOfParticles > 0 &&
            minimumSize.width > 0 &&
            minimumSize.height > 0 &&
            maximumSize.width > 0 &&
            maximumSize.height > 0 &&
            minimumSize.width <= maximumSize.width &&
            minimumSize.height <= maximumSize.height &&
            particleDrag >= 0.0 &&
            particleDrag <= 1 &&
            minimumSize.height <= maximumSize.height),
        assert(gravity >= 0 && gravity <= 1),
        _blastDirection = blastDirection,
        _blastDirectionality = blastDirectionality,
        _gravity = gravity,
        _maxBlastForce = maxBlastForce,
        _minBlastForce = minBlastForce,
        _frequency = emissionFrequency,
        _numberOfParticles = numberOfParticles,
        _colors = colors,
        _minimumSize = minimumSize,
        _maximumSize = maximumSize,
        _particleDrag = particleDrag,
        _rand = Random(),
        _emitterAlignment = emitterAlignment,
        _createParticlePaths = createParticlePaths;

  ParticleSystemStatus? _particleSystemStatus;

  final List<Particle> _particles = [];

  /// A frequency between 0 and 1 to determine how often the emitter
  /// should emit new particles.
  final double _frequency;
  final int _numberOfParticles;
  final double _maxBlastForce;
  final double _minBlastForce;
  final double _blastDirection;
  final BlastDirectionality _blastDirectionality;
  final double _gravity;
  final List<Color>? _colors;
  final Size _minimumSize;
  final Size _maximumSize;
  final double _particleDrag;
  final List<Path Function(Size size)>? _createParticlePaths;
  final AlignmentGeometry _emitterAlignment;

  Offset? _particleSystemPosition;
  Size? _screenSize;

  late double _bottomBorder;
  late double _rightBorder;
  late double _leftBorder;
  late double _topBorder;

  bool isFullScreen = true;

  final Random _rand;

  set particleSystemPosition(Offset? position) {
    _particleSystemPosition = position;
  }

  set screenSize(Size size) {
    _screenSize = size;
    _setScreenBorderPositions(); // needs to be called here to only set the borders once
  }

  void stopParticleEmission() {
    _particleSystemStatus = ParticleSystemStatus.stopped;
  }

  void startParticleEmission() {
    _particleSystemStatus = ParticleSystemStatus.started;
  }

  void finishParticleEmission() {
    _particleSystemStatus = ParticleSystemStatus.finished;
  }

  List<Particle> get particles => _particles;
  ParticleSystemStatus? get particleSystemStatus => _particleSystemStatus;

  void update() {
    _clean();
    if (_particleSystemStatus != ParticleSystemStatus.finished) {
      _updateParticles();
    }

    if (_particleSystemStatus == ParticleSystemStatus.started) {
      // If there are no particles then immediately generate particles
      // This also ensures that particles are emitted on the first frame
      if (particles.isEmpty) {
        _particles.addAll(_generateParticles(number: _numberOfParticles));
        return;
      }

      // Determines whether to generate new particles based on the [frequency]
      final chanceToGenerate = _rand.nextDouble();
      if (chanceToGenerate < _frequency) {
        _particles.addAll(_generateParticles(number: _numberOfParticles));
      }
    }

    if (_particleSystemStatus == ParticleSystemStatus.stopped &&
        _particles.isEmpty) {
      finishParticleEmission();
      notifyListeners();
    }
  }

  void _setScreenBorderPositions() {
    if (isFullScreen) {
      _bottomBorder = _screenSize!.height;
      _rightBorder = _screenSize!.width;
      _leftBorder = 0;
      _topBorder = 0;
    } else {
      if (_particleSystemPosition != null) {
        _calculateSpace();
      } else {
        _bottomBorder = _screenSize!.height;
        _rightBorder = _screenSize!.width;
        _leftBorder = _screenSize!.width - _rightBorder;
        _topBorder = 0;
      }
    }
  }

  void _calculateSpace() {
    List<String> parse = _emitterAlignment
        .toString()
        .split('.')
        .last
        .split(RegExp(r"(?=[A-Z])"));
    if (parse.length == 1) {
      _bottomBorder = _particleSystemPosition!.dy + _screenSize!.height / 2;
      _topBorder = _particleSystemPosition!.dy - _screenSize!.height / 2;
      _leftBorder = _particleSystemPosition!.dx - _screenSize!.width / 2;
      _rightBorder = _particleSystemPosition!.dx + _screenSize!.width / 2;
    } else {
      switch (parse.first) {
        case 'center':
          _bottomBorder = _particleSystemPosition!.dy + _screenSize!.height / 2;
          _topBorder = _particleSystemPosition!.dy - _screenSize!.height / 2;
          break;
        case 'bottom':
          _bottomBorder = _particleSystemPosition!.dy;
          _topBorder = _particleSystemPosition!.dy - _screenSize!.height;
          break;
        case 'top':
          _bottomBorder = _particleSystemPosition!.dy + _screenSize!.height;
          _topBorder = _particleSystemPosition!.dy;
          break;
        default:
          break;
      }
      switch (parse.last) {
        case 'Left':
          _leftBorder = _particleSystemPosition!.dx;
          _rightBorder = _particleSystemPosition!.dx + _screenSize!.width;
          break;
        case 'Center':
          _leftBorder = _particleSystemPosition!.dx - _screenSize!.width / 2;
          _rightBorder = _particleSystemPosition!.dx + _screenSize!.width / 2;
          break;
        case 'Right':
          _leftBorder = _particleSystemPosition!.dx - _screenSize!.width;
          _rightBorder = _particleSystemPosition!.dx;
          break;
        default:
          break;
      }
    }
  }

  void _updateParticles() {
    for (final particle in _particles) {
      particle.update();
    }
  }

  void _clean() {
    if (_particleSystemPosition != null && _screenSize != null) {
      _particles
          .removeWhere((particle) => _isOutsideOfBorder(particle.location));
    }
  }

  bool _isOutsideOfBorder(Offset particleLocation) {
    final globalParticlePosition = particleLocation + _particleSystemPosition!;
    return (globalParticlePosition.dy >= _bottomBorder) ||
        (globalParticlePosition.dx >= _rightBorder) ||
        (globalParticlePosition.dx <= _leftBorder) ||
        (globalParticlePosition.dy <= _topBorder);
  }

  List<Particle> _generateParticles({int number = 1}) {
    if (_createParticlePaths == null || _createParticlePaths!.isEmpty) {
      return List<Particle>.generate(
          number,
          (i) => Particle(_generateParticleForce(), _randomColor(),
              _randomSize(), _gravity, _particleDrag, null, _emitterAlignment));
    } else {
      var defaultParticle = List<Particle>.generate(
          (number * 0.6).floor(),
          (i) => Particle(_generateParticleForce(), _randomColor(),
              _randomSize(), _gravity, _particleDrag, null, _emitterAlignment));
      var customParticle = [];
      var ratePerPath = 0.4 / _createParticlePaths!.length;
      for (var path in _createParticlePaths!) {
        var list = List<Particle>.generate(
            (number * ratePerPath).floor(),
            (i) => Particle(
                _generateParticleForce(),
                _randomColor(),
                _randomSize(),
                _gravity,
                _particleDrag,
                path,
                _emitterAlignment));
        customParticle.addAll(list);
      }
      return [...defaultParticle, ...customParticle]..shuffle();
    }
  }

  double get _randomBlastDirection =>
      vmath.radians(Random().nextInt(359).toDouble());

  vmath.Vector2 _generateParticleForce() {
    var blastDirection = _blastDirection;
    if (_blastDirectionality == BlastDirectionality.explosive) {
      blastDirection = _randomBlastDirection;
    }
    final blastRadius = ConfettiUtils.randomize(_minBlastForce, _maxBlastForce);
    final y = blastRadius * sin(blastDirection);
    final x = blastRadius * cos(blastDirection);
    return vmath.Vector2(x, y);
  }

  Color _randomColor() {
    if (_colors != null) {
      if (_colors!.length == 1) {
        return _colors![0];
      }
      final index = _rand.nextInt(_colors!.length);
      return _colors![index];
    }
    return ConfettiUtils.randomColor();
  }

  Size _randomSize() {
    return Size(
      ConfettiUtils.randomize(_minimumSize.width, _maximumSize.width),
      ConfettiUtils.randomize(_minimumSize.height, _maximumSize.height),
    );
  }
}

class Particle {
  Particle(
      vmath.Vector2 startUpForce,
      Color color,
      Size size,
      double gravity,
      double particleDrag,
      Path Function(Size size)? createParticlePath,
      AlignmentGeometry emitterAlignment)
      : _startUpForce = startUpForce,
        _location = calculateVector(emitterAlignment),
        _color = color,
        _mass = ConfettiUtils.randomize(1, 11),
        _particleDrag = particleDrag,
        _acceleration = vmath.Vector2.zero(),
        _velocity = vmath.Vector2(
            ConfettiUtils.randomize(-3, 3), ConfettiUtils.randomize(-3, 3)),
        // _size = size,
        _pathShape = createParticlePath != null
            ? createParticlePath(size)
            : createPath(size),
        _aVelocityX = ConfettiUtils.randomize(-0.1, 0.1),
        _aVelocityY = ConfettiUtils.randomize(-0.1, 0.1),
        _aVelocityZ = ConfettiUtils.randomize(-0.1, 0.1),
        _gravity = lerpDouble(0.1, 5, gravity);

  final vmath.Vector2 _startUpForce;

  final vmath.Vector2 _location;
  final vmath.Vector2 _velocity;
  final vmath.Vector2 _acceleration;

  final double _particleDrag;
  double _aX = 0;
  double _aVelocityX;
  double _aY = 0;
  double _aVelocityY;
  double _aZ = 0;
  double _aVelocityZ;
  final double? _gravity;
  final _aAcceleration = 0.0001;

  final Color _color;
  final double _mass;
  final Path _pathShape;

  double _timeAlive = 0;

  static Path createPath(Size size) {
    final pathShape = Path()
      ..moveTo(0, 0)
      ..lineTo(-size.width, 0)
      ..lineTo(-size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return pathShape;
  }

  static vmath.Vector2 calculateVector(AlignmentGeometry emitterAlignment) {
    List<String> parse =
        emitterAlignment.toString().split('.').last.split(RegExp(r"(?=[A-Z])"));
    if (parse.length == 1) {
      return vmath.Vector2.zero();
    } else {
      double x = 0;
      double y = 0;
      switch (parse.first) {
        case 'center':
          y = 0;
          break;
        case 'bottom':
          y = -5;
          break;
        case 'top':
          y = 5;
          break;
      }
      switch (parse.last) {
        case 'Left':
          x = 5;
          break;
        case 'Center':
          x = 0;
          break;
        case 'Right':
          x = -5;
          break;
      }
      return vmath.Vector2(x, y);
    }
  }

  void applyForce(vmath.Vector2 force) {
    final f = force.clone()..divide(vmath.Vector2.all(_mass));
    _acceleration.add(f);
  }

  void drag() {
    final speed = sqrt(pow(_velocity.x, 2) + pow(_velocity.y, 2));
    final dragMagnitude = _particleDrag * speed * speed;
    final drag = _velocity.clone()
      ..multiply(vmath.Vector2.all(-1))
      ..normalize()
      ..multiply(vmath.Vector2.all(dragMagnitude));
    applyForce(drag);
  }

  void _applyStartUpForce() {
    applyForce(_startUpForce);
  }

  void _applyWindForceUp() {
    applyForce(vmath.Vector2(0, -1));
  }

  void update() {
    drag();

    if (_timeAlive < 5) {
      _applyStartUpForce();
    }
    if (_timeAlive < 25) {
      _applyWindForceUp();
    }

    _timeAlive += 1;

    applyForce(vmath.Vector2(0, _gravity!));

    _velocity.add(_acceleration);
    _location.add(_velocity);
    _acceleration.setZero();

    _aVelocityX += _aAcceleration / _mass;
    _aVelocityY += _aAcceleration / _mass;
    _aVelocityZ += _aAcceleration / _mass;
    _aX += _aVelocityX;
    _aY += _aVelocityY;
    _aZ += _aVelocityZ;
  }

  Offset get location {
    if (_location.x.isNaN || _location.y.isNaN) {
      return const Offset(0, 0);
    }
    return Offset(_location.x, _location.y);
  }

  Color get color => _color;
  Path get path => _pathShape;

  double get angleX => _aX;
  double get angleY => _aY;
  double get angleZ => _aZ;
}
