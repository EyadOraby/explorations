import 'package:explorations/experiments/text_scale/text_scale.dart';
import 'package:explorations/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('contrast ratio', () {
    test('black on white is 21:1 and a colour on itself is 1:1', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 1e-9));
      expect(contrastRatio(Colors.white, Colors.white), closeTo(1, 1e-9));
    });

    test('order does not matter', () {
      const grey = Color(0xFF767676);
      expect(
        contrastRatio(grey, Colors.white),
        contrastRatio(Colors.white, grey),
      );
    });

    test('#767676 passes AA on white and #777777 just misses', () {
      expect(
        contrastRatio(const Color(0xFF767676), Colors.white),
        closeTo(4.54, 0.01),
      );
      expect(
        contrastRatio(const Color(0xFF777777), Colors.white),
        lessThan(4.5),
      );
      expect(
        contrastRatio(const Color(0xFF9E9E9E), Colors.white),
        closeTo(2.68, 0.01),
      );
    });
  });

  testWidgets('at 200% the adaptive card grows and the fixed one does not', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExplorationsApp(initialSlug: 'text-scale'));
    await tester.pumpAndSettle();

    final fixed = tester.getSize(find.byKey(const Key('card-fixed')));
    final adaptive = tester.getSize(find.byKey(const Key('card-adaptive')));
    expect(fixed.height, 132);
    expect(adaptive.height, greaterThan(fixed.height));
    expect(tester.takeException(), isNull);
  });
}
