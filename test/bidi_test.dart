import 'package:explorations/experiments/bidi/bidi.dart';
import 'package:explorations/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  bidiLayoutTests();

  test('a phone number becomes one isolated run', () {
    expect(
      isolateLtr('اتصل على +20 100 123 4567 الآن'),
      'اتصل على $lri+20 100 123 4567$pdi الآن',
    );
  });

  test('time ranges, prices and codes are isolated whole', () {
    expect(isolateLtr('مفتوح 10:30 - 23:45'), 'مفتوح ${lri}10:30 - 23:45$pdi');
    expect(isolateLtr('السعر EGP 1,250.50'), 'السعر ${lri}EGP 1,250.50$pdi');
    expect(isolateLtr('الطلب TB-4120'), 'الطلب ${lri}TB-4120$pdi');
  });

  test(
    'Arabic on its own is left alone, and running twice changes nothing',
    () {
      expect(isolateLtr('مرحبا بك'), 'مرحبا بك');
      final once = isolateLtr('اتصل على +20 100 123 4567');
      expect(isolateLtr(once), once);
    },
  );

  testWidgets('the demo shows each sample as typed and isolated', (
    tester,
  ) async {
    await tester.pumpWidget(const ExplorationsApp(initialSlug: 'bidi'));
    await tester.pumpAndSettle();
    expect(find.text('As typed'), findsNWidgets(BidiDemo.samples.length));
    expect(find.text('Isolated'), findsNWidgets(BidiDemo.samples.length));
  });
}

/// Where a character of [text] lands on screen, laid out right to left.
double _x(String text, int index) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: const TextStyle(fontSize: 20)),
    textDirection: TextDirection.rtl,
  )..layout();
  final boxes = painter.getBoxesForSelection(
    TextSelection(baseOffset: index, extentOffset: index + 1),
  );
  return boxes.first.left;
}

void bidiLayoutTests() {
  const typed = 'اتصل على +20 100 123 4567 الآن';
  test('as typed, the plus sign lands to the right of the last group', () {
    final plus = typed.indexOf('+');
    final last = typed.indexOf('4567');
    expect(_x(typed, plus), greaterThan(_x(typed, last)));
  });

  test('isolated, the number reads left to right as one unit', () {
    final fixed = isolateLtr(typed);
    final plus = fixed.indexOf('+');
    final last = fixed.indexOf('4567');
    expect(_x(fixed, plus), lessThan(_x(fixed, last)));
  });
}
