import 'package:material_ui/material_ui.dart';

import '../../experiment.dart';
import '../../theme.dart';

final staggerExperiment = Experiment(
  slug: 'stagger',
  title: 'Staggered entrances',
  question:
      'Can one AnimationController run a staggered list entrance, and what '
      'should the list do when someone turns animations off?',
  notes: const [
    'One controller with an Interval per row beats one controller per row: a '
        'single ticker, a single dispose, and the rows can never drift apart.',
    'Overlap is the real knob. With none, eight rows feel slow; at about 60% '
        'they still read as a sequence and the whole list lands in under 700 ms.',
    'Cap the total time. Per-row timing that grows with the list makes long '
        'lists feel broken, so the stagger shrinks as the count goes up.',
    'MediaQuery.disableAnimationsOf(context) follows the system setting. '
        'When it is on, the rows appear at once: no slide, not a shorter slide.',
  ],
  started: '2026-11-22',
  builder: (_) => const StaggerDemo(),
);

/// The slice of the controller's 0..1 timeline that row [index] animates in.
///
/// Rows start one after another, [overlap] of a row's slot overlapping the
/// next (0 = strictly one after the other, 0.9 = nearly together).
({double begin, double end}) staggerInterval(
  int index,
  int count, {
  double overlap = 0.6,
}) {
  assert(count > 0 && index >= 0 && index < count);
  assert(overlap >= 0 && overlap < 1);
  // Each row lasts `slot`; the next one starts (1 - overlap) of a slot later,
  // and the last row ends exactly at 1.
  final slot = 1 / (count - (count - 1) * overlap);
  final begin = index * slot * (1 - overlap);
  return (begin: begin, end: (begin + slot).clamp(0.0, 1.0));
}

/// Total entrance time: grows with the list but is capped.
Duration staggerDuration(int count) =>
    Duration(milliseconds: (260 + 60 * count).clamp(260, 700));

class StaggerDemo extends StatefulWidget {
  const StaggerDemo({super.key});

  @override
  State<StaggerDemo> createState() => _StaggerDemoState();
}

class _StaggerDemoState extends State<StaggerDemo>
    with SingleTickerProviderStateMixin {
  static const _rows = [
    ('Koshary', 'Order TB-4120 · on the way'),
    ('Ful medames', 'Order TB-4121 · being cooked'),
    ('Feteer meshaltet', 'Order TB-4122 · placed'),
    ('Molokhia', 'Order TB-4123 · delivered'),
    ('Hawawshi', 'Order TB-4124 · delivered'),
    ('Om Ali', 'Order TB-4125 · delivered'),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: staggerDuration(_rows.length),
  );
  double _overlap = 0.6;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    if (_reduceMotion || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final still = _reduceMotion || MediaQuery.disableAnimationsOf(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, row) in _rows.indexed)
          _StaggerRow(
            animation: still
                ? const AlwaysStoppedAnimation(1.0)
                : CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      staggerInterval(i, _rows.length, overlap: _overlap).begin,
                      staggerInterval(i, _rows.length, overlap: _overlap).end,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
            title: row.$1,
            subtitle: row.$2,
          ),
        const SizedBox(height: 16),
        Text(
          'Overlap ${(100 * _overlap).round()}%',
          style: text.labelLarge?.copyWith(color: muted),
        ),
        Slider(
          value: _overlap,
          max: 0.9,
          divisions: 9,
          label: '${(100 * _overlap).round()}%',
          onChanged: (v) => setState(() => _overlap = v),
          onChangeEnd: (_) => _replay(),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduce motion'),
          subtitle: const Text('What the system setting does'),
          value: _reduceMotion,
          onChanged: (v) {
            setState(() => _reduceMotion = v);
            _replay();
          },
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: _replay,
            icon: const Icon(Icons.replay),
            label: const Text('Replay'),
          ),
        ),
      ],
    );
  }
}

class _StaggerRow extends StatelessWidget {
  const _StaggerRow({
    required this.animation,
    required this.title,
    required this.subtitle,
  });

  final Animation<double> animation;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: paper,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: rule),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: accent.withValues(alpha: 0.12),
              foregroundColor: accent,
              child: Text(title.characters.first),
            ),
            title: Text(title),
            subtitle: Text(subtitle),
          ),
        ),
      ),
    );
  }
}
