import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayerly/services/dhikr_service.dart';
import 'package:prayerly/widgets/dhikar/dhikr_counter_widget.dart';

/// Reads the progress value the counter actually hands to its painter.
double _drawnProgress(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(DhikrCounterWidget),
      matching: find.byWidgetPredicate(
        (w) => w is CustomPaint && w.size == const Size(260, 260),
      ),
    ),
  );

  // The painter type is private to the widget under test, so reach its
  // progress field dynamically rather than exporting it just for a test.
  return (paint.painter as dynamic).progress as double;
}

Future<void> _pumpCounter(
  WidgetTester tester, {
  required int count,
  required int target,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DhikrCounterWidget(
          count: count,
          targetCount: target,
          onTap: () {},
          onReset: () {},
          onTargetEdit: () {},
        ),
      ),
    ),
  );
  // Let the progress tween settle.
  await tester.pumpAndSettle();
}

void main() {
  group('DhikrService.calculateProgress', () {
    test('is a plain ratio, clamped to 0..1', () {
      expect(DhikrService.calculateProgress(33, 100), closeTo(0.33, 1e-9));
      expect(DhikrService.calculateProgress(0, 100), 0.0);
      expect(DhikrService.calculateProgress(100, 100), 1.0);
      expect(DhikrService.calculateProgress(150, 100), 1.0);
      expect(DhikrService.calculateProgress(5, 0), 0.0);
    });
  });

  group('counter ring', () {
    // Regression: the ring was driven through a CurvedAnimation whose parent
    // value *was* the progress, so easeOut was applied to the value instead
    // of to time. 33 of 100 drew an arc at 48.5%, and 40 drew 57%.
    testWidgets('draws exactly count / target, not an eased value',
        (tester) async {
      await _pumpCounter(tester, count: 33, target: 100);
      expect(_drawnProgress(tester), closeTo(0.33, 0.001));
    });

    testWidgets('matches the percentage label it displays', (tester) async {
      await _pumpCounter(tester, count: 40, target: 100);

      expect(_drawnProgress(tester), closeTo(0.40, 0.001));
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('half the count is half the ring', (tester) async {
      await _pumpCounter(tester, count: 50, target: 100);
      expect(_drawnProgress(tester), closeTo(0.50, 0.001));
    });

    testWidgets('an empty counter draws nothing', (tester) async {
      await _pumpCounter(tester, count: 0, target: 33);
      expect(_drawnProgress(tester), 0.0);
    });

    testWidgets('a met target fills the ring and marks completion',
        (tester) async {
      await _pumpCounter(tester, count: 33, target: 33);

      expect(_drawnProgress(tester), 1.0);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('overshooting the target does not overfill', (tester) async {
      await _pumpCounter(tester, count: 120, target: 100);
      expect(_drawnProgress(tester), 1.0);
    });

    testWidgets('animates towards a new count without overshooting it',
        (tester) async {
      await _pumpCounter(tester, count: 30, target: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DhikrCounterWidget(
              count: 31,
              targetCount: 100,
              onTap: () {},
              onReset: () {},
              onTargetEdit: () {},
            ),
          ),
        ),
      );

      // Mid-flight the arc must stay between the old and new values.
      await tester.pump(const Duration(milliseconds: 100));
      final midFlight = _drawnProgress(tester);
      expect(midFlight, greaterThanOrEqualTo(0.30));
      expect(midFlight, lessThanOrEqualTo(0.31));

      await tester.pumpAndSettle();
      expect(_drawnProgress(tester), closeTo(0.31, 0.001));
    });
  });
}
