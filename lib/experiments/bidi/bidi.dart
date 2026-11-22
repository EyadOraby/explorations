import 'package:material_ui/material_ui.dart';

import '../../experiment.dart';
import '../../theme.dart';

final bidiExperiment = Experiment(
  slug: 'bidi',
  title: 'Numbers inside Arabic',
  question:
      'Why do phone numbers, time ranges and prices come out scrambled inside '
      'an Arabic sentence, and what is the smallest fix?',
  notes: const [
    'Digits are "weak" in the Unicode bidi algorithm. Inside right-to-left '
        'text, groups separated by spaces or dashes are laid out right to left, '
        'so +20 100 123 4567 reads 4567 123 100 20+.',
    'Wrapping each left-to-right run in U+2066 (left-to-right isolate) and '
        'U+2069 (pop isolate) keeps it in reading order without changing the '
        'sentence around it.',
    'Isolates are better than the older marks (U+200E): they do not leak '
        'into the text after them, so punctuation stays where it belongs.',
    'Do it where text is built (formatting a phone number or a price), not '
        'by fixing strings one by one in translations.',
  ],
  started: '2026-11-23',
  builder: (_) => const BidiDemo(),
);

/// Left-to-right isolate (U+2066) and pop directional isolate (U+2069).
final lri = String.fromCharCode(0x2066);
final pdi = String.fromCharCode(0x2069);

/// A run of left-to-right content: Latin words, digits and the punctuation
/// that joins them, including spaces between such tokens.
final _ltrRun = RegExp(
  r'[+]?[A-Za-z0-9][A-Za-z0-9\-./:,#%]*'
  r'(?:(?:\s*[-\u2013/]\s*|\s)[+]?[A-Za-z0-9][A-Za-z0-9\-./:,#%]*)*',
);

/// Wraps every left-to-right run in [text] in a left-to-right isolate.
String isolateLtr(String text) => text
    .replaceAll(lri, '')
    .replaceAll(pdi, '')
    .replaceAllMapped(_ltrRun, (m) => '$lri${m[0]}$pdi');

class BidiDemo extends StatelessWidget {
  const BidiDemo({super.key});

  static const samples = [
    ('Phone number', 'اتصل بنا على +20 100 123 4567 في أي وقت'),
    ('Time range', 'المطعم مفتوح 10:30 - 23:45 كل يوم'),
    ('Price', 'الإجمالي EGP 1,250.50 شامل التوصيل'),
    ('Order code', 'تم شحن الطلب TB-4120 / 3 اليوم'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, sample) in samples) ...[
          Text(label, style: text.labelLarge?.copyWith(color: muted)),
          const SizedBox(height: 6),
          _Row(kind: 'As typed', value: sample, good: false),
          const SizedBox(height: 6),
          _Row(kind: 'Isolated', value: isolateLtr(sample), good: true),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.kind, required this.value, required this.good});

  final String kind;
  final String value;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colour = good ? const Color(0xFF1B7F4B) : const Color(0xFFB3261E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rule),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              kind,
              style: text.labelMedium?.copyWith(
                color: colour,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(value, style: text.titleMedium),
            ),
          ),
        ],
      ),
    );
  }
}
