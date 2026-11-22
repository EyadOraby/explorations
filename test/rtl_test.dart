import 'package:explorations/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Where a card's badge sits: below 0.5 is the left half, above is the right.
double _badgeSide(WidgetTester tester, String kind) {
  final card = tester.getRect(find.byKey(Key('card-$kind')));
  final badge = tester.getCenter(find.byKey(Key('badge-$kind')));
  return (badge.dx - card.left) / card.width;
}

void main() {
  testWidgets('in Arabic only the start/end badge moves to the right', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExplorationsApp(initialSlug: 'rtl'));
    await tester.pumpAndSettle();

    // Arabic is the default.
    expect(_badgeSide(tester, 'directional'), greaterThan(0.5));
    expect(_badgeSide(tester, 'hardcoded'), lessThan(0.5));

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(_badgeSide(tester, 'directional'), lessThan(0.5));
    expect(_badgeSide(tester, 'hardcoded'), lessThan(0.5));
  });
}
