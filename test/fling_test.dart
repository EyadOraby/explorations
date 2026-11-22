import 'package:explorations/experiments/fling/fling.dart';
import 'package:explorations/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('shouldThrow', () {
    test('a slow drag past halfway is thrown', () {
      expect(shouldThrow(200, 50, 400), isTrue);
      expect(shouldThrow(-200, -50, 400), isTrue);
    });

    test('a short slow drag springs back', () {
      expect(shouldThrow(60, 100, 400), isFalse);
    });

    test('a fast flick is thrown even from near the start', () {
      expect(shouldThrow(20, 1200, 400), isTrue);
      expect(shouldThrow(0, -900, 400), isTrue);
    });

    test('flicking back towards the middle is not a throw', () {
      expect(shouldThrow(80, -1200, 400), isFalse);
    });
  });

  testWidgets('a thrown card comes back to the middle', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExplorationsApp(initialSlug: 'fling'));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('fling-card'));
    final start = tester.getCenter(card).dx;

    await tester.fling(card, const Offset(250, 0), 2000);
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.getCenter(card).dx, greaterThan(start + 100));

    await tester.pumpAndSettle();
    expect(find.textContaining('Thrown at'), findsOneWidget);
    expect(tester.getCenter(card).dx, closeTo(start, 1));
    expect(find.text('Card 2'), findsOneWidget);
  });
}
