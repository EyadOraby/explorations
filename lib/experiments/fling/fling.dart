import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

import '../../experiment.dart';
import '../../theme.dart';

final flingExperiment = Experiment(
  slug: 'fling',
  title: 'Flinging a card',
  question:
      'How do I make a dragged card behave like a real object: fly off when '
      'thrown, spring back when let go gently?',
  notes: const [
    'Decide on release, from both distance and speed. A slow drag past '
        'halfway and a fast flick from near the start should both throw the card.',
    'An AnimationController can run a physics simulation directly with '
        'animateWith, so the card keeps the speed of the finger instead of '
        'restarting from zero.',
    'A spring settles back far more naturally than a curve. Damping is the '
        'knob that matters: too little and it wobbles, too much and it feels '
        'sticky.',
    'The drag must feel attached to the finger: move the card by the exact '
        'delta, and only hand over to physics when the finger lets go.',
  ],
  started: '2026-11-23',
  builder: (_) => const FlingDemo(),
);

/// Whether a card released at [offset] with [velocity] (both in logical
/// pixels, along x) should fly off a stage [width] wide.
bool shouldThrow(double offset, double velocity, double width) {
  if (velocity.abs() > 700) return velocity.sign == offset.sign || offset == 0;
  return offset.abs() > width * 0.45;
}

class FlingDemo extends StatefulWidget {
  const FlingDemo({super.key});

  @override
  State<FlingDemo> createState() => _FlingDemoState();
}

class _FlingDemoState extends State<FlingDemo>
    with SingleTickerProviderStateMixin {
  // Unbounded so physics can carry the card off the stage.
  late final AnimationController _x = AnimationController.unbounded(
    vsync: this,
  );
  double _stiffness = 300;
  double _damping = 18;
  int _thrown = 0;
  bool _dragging = false;
  String _last = 'Drag the card and let go.';

  @override
  void dispose() {
    _x.dispose();
    super.dispose();
  }

  void _release(double velocity, double width) {
    final still = MediaQuery.disableAnimationsOf(context);
    if (shouldThrow(_x.value, velocity, width)) {
      final direction = (_x.value == 0 ? velocity : _x.value).sign;
      setState(() {
        _thrown++;
        _last =
            'Thrown at ${velocity.abs().round()} px/s. It comes back in a moment.';
      });
      if (still) {
        _x.value = 0;
        return;
      }
      _x
          .animateWith(
            FrictionSimulation(
              0.15,
              _x.value,
              velocity == 0 ? direction * 1500 : velocity,
            ),
          )
          .whenCompleteOrCancel(() {
            if (!mounted || _dragging) return;
            // Bring a fresh card in from the other side.
            _x.value = -direction * width;
            _x.animateWith(
              SpringSimulation(
                SpringDescription(
                  mass: 1,
                  stiffness: _stiffness,
                  damping: _damping,
                ),
                _x.value,
                0,
                0,
              ),
            );
          });
      // Friction alone never stops off-stage; cap the throw at the edge.
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && _x.isAnimating && _x.value.abs() > width) _x.stop();
      });
    } else {
      setState(
        () => _last =
            'Let go at ${velocity.abs().round()} px/s: not enough, so it springs back.',
      );
      if (still) {
        _x.value = 0;
        return;
      }
      _x.animateWith(
        SpringSimulation(
          SpringDescription(mass: 1, stiffness: _stiffness, damping: _damping),
          _x.value,
          0,
          velocity,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 220,
              child: ClipRect(
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragStart: (_) {
                      _dragging = true;
                      _x.stop();
                    },
                    onHorizontalDragUpdate: (d) => _x.value += d.delta.dx,
                    onHorizontalDragEnd: (d) {
                      _dragging = false;
                      _release(d.velocity.pixelsPerSecond.dx, width);
                    },
                    child: AnimatedBuilder(
                      animation: _x,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_x.value, 0),
                        child: Transform.rotate(
                          angle: (_x.value / width).clamp(-1.0, 1.0) * 0.35,
                          child: child,
                        ),
                      ),
                      child: _Card(number: _thrown + 1),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              _last,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 16),
            Text(
              'Spring stiffness ${_stiffness.round()}',
              style: text.labelLarge?.copyWith(color: muted),
            ),
            Slider(
              value: _stiffness,
              min: 80,
              max: 800,
              onChanged: (v) => setState(() => _stiffness = v),
            ),
            Text(
              'Damping ${_damping.round()}',
              style: text.labelLarge?.copyWith(color: muted),
            ),
            Slider(
              value: _damping,
              min: 4,
              max: 50,
              onChanged: (v) => setState(() => _damping = v),
            ),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      key: const Key('fling-card'),
      width: 200,
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card $number',
            style: text.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Throw me left or right',
            style: text.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
