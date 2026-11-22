import 'package:explorations/experiments/stagger/stagger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rows run back to back with no overlap', () {
    expect(staggerInterval(0, 4, overlap: 0), (begin: 0.0, end: 0.25));
    expect(staggerInterval(3, 4, overlap: 0), (begin: 0.75, end: 1.0));
  });

  test('the first row starts at 0 and the last ends at 1 for any overlap', () {
    for (final overlap in [0.0, 0.3, 0.6, 0.9]) {
      for (final count in [1, 2, 6, 20]) {
        final first = staggerInterval(0, count, overlap: overlap);
        final last = staggerInterval(count - 1, count, overlap: overlap);
        expect(first.begin, 0);
        expect(last.end, closeTo(1, 1e-9), reason: '$count rows, $overlap');
      }
    }
  });

  test('each row starts after the one before it', () {
    for (var i = 1; i < 6; i++) {
      expect(
        staggerInterval(i, 6).begin,
        greaterThan(staggerInterval(i - 1, 6).begin),
      );
    }
  });

  test('the total time grows with the list but is capped', () {
    expect(staggerDuration(2), lessThan(staggerDuration(6)));
    expect(staggerDuration(50), const Duration(milliseconds: 700));
  });
}
