import 'package:material_ui/material_ui.dart';

import '../../experiment.dart';
import '../../theme.dart';

final rtlExperiment = Experiment(
  slug: 'rtl',
  title: 'Mirroring a layout for Arabic',
  question:
      'When the app switches to Arabic, which parts of a layout flip on their '
      'own, and which ones only flip if I write them the right way?',
  notes: const [
    'Row, ListTile, LinearProgressIndicator, Slider and the back button follow '
        'Directionality with no extra work.',
    'EdgeInsets.only(left:), Alignment.centerLeft, Positioned(left:) and '
        'Border(left:) stay where they are. Their Directional twins, with start '
        'and end, flip.',
    "Material's arrow icons set matchTextDirection, so they mirror. An arrow "
        'typed as text, or a custom icon, does not.',
    'Searching the code for "left:" and "centerLeft" finds most right-to-left '
        'bugs before a user does.',
  ],
  started: '2026-11-22',
  builder: (_) => const RtlDemo(),
);

/// The same card twice: once with left/right values, once with start/end.
class RtlDemo extends StatefulWidget {
  const RtlDemo({super.key});

  @override
  State<RtlDemo> createState() => _RtlDemoState();
}

class _RtlDemoState extends State<RtlDemo> {
  bool _arabic = true;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _OrderCard(directional: false, arabic: _arabic),
      _OrderCard(directional: true, arabic: _arabic),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('English')),
              ButtonSegment(value: true, label: Text('العربية')),
            ],
            selected: {_arabic},
            onSelectionChanged: (s) => setState(() => _arabic = s.first),
          ),
        ),
        const SizedBox(height: 16),
        Directionality(
          textDirection: _arabic ? TextDirection.rtl : TextDirection.ltr,
          child: LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 600
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  )
                : Column(
                    children: [cards[0], const SizedBox(height: 16), cards[1]],
                  ),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.directional, required this.arabic});

  final bool directional;
  final bool arabic;

  String _t(String en, String ar) => arabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final label = directional ? 'start / end' : 'left / right';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: text.labelLarge?.copyWith(
            color: directional
                ? const Color(0xFF1B7F4B)
                : const Color(0xFFB3261E),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          key: Key(directional ? 'card-directional' : 'card-hardcoded'),
          children: [
            Material(
              color: paper,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: rule),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row flips by itself in both cards.
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: accent.withValues(alpha: 0.12),
                          foregroundColor: accent,
                          child: Text(_t('K', 'ك')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('Koshary', 'كشري'),
                                style: text.titleMedium,
                              ),
                              Text(
                                _t('On the way', 'في الطريق'),
                                style: text.bodySmall?.copyWith(color: muted),
                              ),
                            ],
                          ),
                        ),
                        Text(_t('EGP 270', '270 ج.م'), style: text.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(value: 0.65),
                    const SizedBox(height: 14),
                    // A note with a coloured rule on its leading side.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: directional
                            ? const BorderDirectional(
                                start: BorderSide(color: accent, width: 3),
                              )
                            : const Border(
                                left: BorderSide(color: accent, width: 3),
                              ),
                      ),
                      child: Padding(
                        padding: directional
                            ? const EdgeInsetsDirectional.only(start: 12)
                            : const EdgeInsets.only(left: 12),
                        child: Align(
                          alignment: directional
                              ? AlignmentDirectional.centerStart
                              : Alignment.centerLeft,
                          child: Text(
                            _t('Ring the bell twice', 'رن الجرس مرتين'),
                            style: text.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: directional
                          ? AlignmentDirectional.centerEnd
                          : Alignment.centerRight,
                      child: directional
                          ? FilledButton.icon(
                              onPressed: () {},
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(_t('Track', 'تتبع')),
                            )
                          : FilledButton(
                              onPressed: () {},
                              child: Text('${_t('Track', 'تتبع')}  →'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (directional)
              PositionedDirectional(
                start: 12,
                top: 0,
                child: _Badge(
                  key: const Key('badge-directional'),
                  label: _t('New', 'جديد'),
                ),
              )
            else
              Positioned(
                left: 12,
                top: 0,
                child: _Badge(
                  key: const Key('badge-hardcoded'),
                  label: _t('New', 'جديد'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
