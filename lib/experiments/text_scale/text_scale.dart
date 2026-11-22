import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../experiment.dart';
import '../../theme.dart';

final textScaleExperiment = Experiment(
  slug: 'text-scale',
  title: 'Text at 200%',
  question:
      'How do I keep a dense card readable when someone sets their text size '
      'to 200%, and which greys are still readable at all?',
  notes: const [
    'Fixed heights and one-line labels are where large text breaks. Nothing '
        'overflows on screen; the words just disappear behind an ellipsis.',
    'Decide the layout from the scaled size, not the setting: '
        'textScaler.scale(14) says how big body text really is. Past about 22 px, '
        'the buttons stack.',
    '#767676 is the lightest grey that reaches 4.5:1 on white, the WCAG AA '
        'bar for body text. The #9E9E9E grey often used for hints only reaches '
        'about 2.7:1.',
    'Wrapping the card in MergeSemantics turns five separate screen reader '
        'stops into one sentence, while the buttons stay their own stops.',
  ],
  started: '2026-11-22',
  builder: (_) => const TextScaleDemo(),
);

/// WCAG relative luminance of a colour (alpha ignored).
double relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio between two colours, from 1 (same) to 21.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

class TextScaleDemo extends StatefulWidget {
  const TextScaleDemo({super.key});

  @override
  State<TextScaleDemo> createState() => _TextScaleDemoState();
}

class _TextScaleDemoState extends State<TextScaleDemo> {
  double _scale = 2;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Text size ${(_scale * 100).round()}%',
          style: text.labelLarge?.copyWith(color: muted),
        ),
        Slider(
          value: _scale,
          min: 1,
          max: 2,
          divisions: 10,
          label: '${(_scale * 100).round()}%',
          onChanged: (v) => setState(() => _scale = v),
        ),
        MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(_scale)),
          child: LayoutBuilder(
            builder: (context, c) {
              final cards = [
                const _Labelled(label: 'Fixed', child: _FixedCard()),
                const _Labelled(label: 'Adaptive', child: _AdaptiveCard()),
              ];
              return c.maxWidth >= 620
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: cards[1]),
                      ],
                    )
                  : Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 16),
                        cards[1],
                      ],
                    );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Grey text on white',
          style: text.labelLarge?.copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        for (final grey in const [
          Color(0xFF9E9E9E),
          Color(0xFF8A8A8A),
          Color(0xFF767676),
          Color(0xFF5E636B),
        ])
          _ContrastRow(colour: grey),
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The label itself stays at normal size, so it is not part of the test.
        MediaQuery.withNoTextScaling(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: muted),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

const _doctor = 'Dr. Mona Adel, physiotherapy';
const _when = 'Tuesday 10:30 · Giza clinic';

BoxDecoration _cardBox() => BoxDecoration(
  color: paper,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: rule),
);

/// Written the usual way: a fixed height, one line per label, buttons in a row.
class _FixedCard extends StatelessWidget {
  const _FixedCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      key: const Key('card-fixed'),
      height: 132,
      padding: const EdgeInsets.all(14),
      decoration: _cardBox(),
      clipBehavior: Clip.hardEdge,
      // Like most fixed-height cards, whatever does not fit is cut off.
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _doctor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium,
            ),
            Text(
              _when,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text(
                      'Confirm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text(
                      'Reschedule',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Grows with the text, and stacks the buttons once body text passes 22 px.
class _AdaptiveCard extends StatelessWidget {
  const _AdaptiveCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final stack = MediaQuery.textScalerOf(context).scale(14) > 22;
    final buttons = [
      FilledButton(onPressed: () {}, child: const Text('Confirm')),
      OutlinedButton(onPressed: () {}, child: const Text('Reschedule')),
    ];
    return Container(
      key: const Key('card-adaptive'),
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(14),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_doctor, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(_when, style: text.bodyMedium?.copyWith(color: muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (stack) ...[
            buttons[0],
            const SizedBox(height: 8),
            buttons[1],
          ] else
            Row(
              children: [
                Expanded(child: buttons[0]),
                const SizedBox(width: 8),
                Expanded(child: buttons[1]),
              ],
            ),
        ],
      ),
    );
  }
}

class _ContrastRow extends StatelessWidget {
  const _ContrastRow({required this.colour});

  final Color colour;

  @override
  Widget build(BuildContext context) {
    final ratio = contrastRatio(colour, Colors.white);
    final pass = ratio >= 4.5;
    final hex = colour.toARGB32().toRadixString(16).substring(2).toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rule),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '#$hex  Book your appointment',
              style: TextStyle(color: colour, fontSize: 15),
            ),
          ),
          Text(
            '${ratio.toStringAsFixed(2)} : 1',
            style: const TextStyle(
              color: ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            pass ? 'AA' : 'Fails',
            style: TextStyle(
              color: pass ? const Color(0xFF1B7F4B) : const Color(0xFFB3261E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
