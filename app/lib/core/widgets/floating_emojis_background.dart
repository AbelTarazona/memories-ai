import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingEmojisBackground extends StatefulWidget {
  /// Lista de rutas de assets PNG (por ejemplo: ['assets/emoji1.png', 'assets/emoji2.png'])
  final List<String> assets;

  /// Duración de la ráfaga inicial de spawns (solo al inicio)
  final Duration burstDuration;

  /// Emojis por segundo durante la ráfaga
  final double spawnRatePerSecond;

  /// Límite de partículas vivas al mismo tiempo
  final int maxParticles;

  /// Rango de tamaños en px (ancho/alto del PNG)
  final double minSize;
  final double maxSize;

  /// Rango de duración de subida (tiempo de vida)
  final Duration minLifespan;
  final Duration maxLifespan;

  /// Amplitud horizontal de la oscilación (px)
  final double minAmplitude;
  final double maxAmplitude;

  /// Frecuencia base de la oscilación
  final double minFrequency;
  final double maxFrequency;

  /// Padding interno del área donde pueden nacer
  final EdgeInsets areaPadding;

  const FloatingEmojisBackground({
    super.key,
    required this.assets,
    this.burstDuration = const Duration(seconds: 6),
    this.spawnRatePerSecond = 6, // ~6 por segundo (ajústalo a gusto)
    this.maxParticles = 40,
    this.minSize = 28,
    this.maxSize = 56,
    this.minLifespan = const Duration(seconds: 3),
    this.maxLifespan = const Duration(seconds: 6),
    this.minAmplitude = 18,
    this.maxAmplitude = 56,
    this.minFrequency = 0.8,
    this.maxFrequency = 1.6,
    this.areaPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<FloatingEmojisBackground> createState() =>
      _FloatingEmojisBackgroundState();
}

class _FloatingEmojisBackgroundState extends State<FloatingEmojisBackground>
    with TickerProviderStateMixin {
  final _rand = math.Random();
  final List<_Particle> _particles = [];
  Timer? _spawner;
  late DateTime _burstEndsAt;

  @override
  void initState() {
    super.initState();
    _burstEndsAt = DateTime.now().add(widget.burstDuration);
    _startBurstSpawner();
  }

  void _startBurstSpawner() {
    final intervalMs = (1000 / widget.spawnRatePerSecond)
        .clamp(16, 2000)
        .toInt();
    _spawner = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!mounted) return;
      if (DateTime.now().isAfter(_burstEndsAt)) {
        _spawner?.cancel();
        return;
      }
      if (_particles.length >= widget.maxParticles) return;
      _spawnOne();
    });
  }

  void _spawnOne() {
    // Safety check: don't spawn if no assets available
    if (widget.assets.isEmpty) return;

    final controller = AnimationController(
      vsync: this,
      duration: _randDuration(widget.minLifespan, widget.maxLifespan),
    );

    final p = _Particle(
      controller: controller,
      asset: widget.assets[_rand.nextInt(widget.assets.length)],
      size: _randDouble(widget.minSize, widget.maxSize),
      startXFactor: _rand.nextDouble(), // 0..1 relativo al ancho
      amplitude: _randDouble(widget.minAmplitude, widget.maxAmplitude),
      frequency: _randDouble(widget.minFrequency, widget.maxFrequency),
      phase: _randDouble(0, math.pi * 2),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (mounted) {
          setState(() => _particles.remove(p));
        }
      }
    });

    setState(() {
      _particles.add(p);
    });

    controller.forward();
  }

  double _randDouble(double min, double max) =>
      min + _rand.nextDouble() * (max - min);
  Duration _randDuration(Duration min, Duration max) {
    final diff = max - min;
    return min +
        Duration(
          milliseconds: (_rand.nextDouble() * diff.inMilliseconds).toInt(),
        );
  }

  @override
  void dispose() {
    _spawner?.cancel();
    for (final p in _particles) {
      p.controller.dispose();
    }
    _particles.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - widget.areaPadding.horizontal;
          final height = constraints.maxHeight - widget.areaPadding.vertical;

          return Stack(
            children: [
              for (final p in _particles)
                AnimatedBuilder(
                  animation: p.controller,
                  builder: (context, _) {
                    final t = Curves.easeOut.transform(p.controller.value);

                    // Y: desde debajo del área visible hasta por encima del top
                    final startY =
                        height + p.size; // comienza fuera de pantalla
                    final endY = -p.size; // termina fuera de pantalla
                    final y = lerpDouble(startY, endY, t)!;

                    // X base: factor * ancho, con padding. Luego oscilación senoidal
                    final baseX =
                        widget.areaPadding.left + p.startXFactor * width;
                    final x =
                        baseX +
                        p.amplitude *
                            math.sin((t * p.frequency * math.pi * 2) + p.phase);

                    // Opacidad: fade out progresivo (puedes afilar la curva si quieres)
                    final opacity = (1.0 - t).clamp(0, 1);

                    // Pequeña animación de escala (0.9 -> 1.0)
                    final scale =
                        0.9 +
                        0.1 * Curves.easeOut.transform((t * 1.2).clamp(0, 1));

                    return Positioned(
                      left: x,
                      top: widget.areaPadding.top + y,
                      child: Opacity(
                        opacity: opacity.toDouble(),
                        child: Transform.scale(
                          scale: scale,
                          child: RepaintBoundary(
                            child: Image.asset(
                              p.asset,
                              width: p.size,
                              height: p.size,
                              filterQuality: FilterQuality
                                  .low, // mejor rendimiento para PNG pequeños
                              isAntiAlias: true,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  final AnimationController controller;
  final String asset;
  final double size;
  final double startXFactor; // 0..1 relativo al ancho disponible
  final double amplitude;
  final double frequency;
  final double phase;

  _Particle({
    required this.controller,
    required this.asset,
    required this.size,
    required this.startXFactor,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });
}
