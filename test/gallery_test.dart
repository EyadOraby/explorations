import 'package:explorations/experiments.dart';
import 'package:explorations/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the gallery lists every experiment', (tester) async {
    await tester.pumpWidget(const ExplorationsApp());
    expect(find.text('Explorations'), findsOneWidget);
    for (final e in experiments) {
      await tester.scrollUntilVisible(
        find.text(e.title),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(e.title), findsOneWidget);
    }
  });

  test('slugs are unique and dates are YYYY-MM-DD', () {
    final slugs = experiments.map((e) => e.slug).toSet();
    expect(slugs.length, experiments.length);
    for (final e in experiments) {
      expect(
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(e.started),
        isTrue,
        reason: e.slug,
      );
      expect(e.notes, isNotEmpty, reason: e.slug);
    }
  });

  testWidgets('each experiment opens on its own', (tester) async {
    for (final e in experiments) {
      await tester.pumpWidget(
        ExplorationsApp(key: ValueKey(e.slug), initialSlug: e.slug),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('What I learned'), findsOneWidget, reason: e.slug);
      expect(tester.takeException(), isNull, reason: e.slug);
    }
  });
}
