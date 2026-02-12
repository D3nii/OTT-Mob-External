import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';
import 'labeled_toggle_fixture.dart';

void main() {
  group('LabeledToggle.build', () {
    testWidgets('with any state', (tester) async {
      final fixture = LabeledToggleFixture(initialValue: false);

      await tester.pumpWidget(fixture.build(enabled: true, label: 'Label'));

      expect(find.text('Label'), findsOneWidget);
      Switch materialSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(materialSwitch.activeTrackColor, tealish);
      expect(materialSwitch.inactiveThumbColor, Colors.white);
    });

    testWidgets('with enabled state', (tester) async {
      final fixture = LabeledToggleFixture(initialValue: false);

      await tester.pumpWidget(fixture.build(enabled: true, label: 'Label'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(fixture.onChangedCalls, isNotEmpty);
      expect(fixture.onChangedCalls.last, isTrue);
    });

    testWidgets('with disabled state', (tester) async {
      final fixture = LabeledToggleFixture(initialValue: true);

      await tester.pumpWidget(fixture.build(enabled: false, label: 'Label'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(fixture.onChangedCalls, isEmpty);
      final Switch updatedSwitch = tester.widget<Switch>(find.byType(Switch));
    });
  });

  group('LabeledToggle.onChanged', () {
    testWidgets('with toggle interaction', (tester) async {
      final fixture = LabeledToggleFixture(initialValue: false);

      await tester.pumpWidget(fixture.build(enabled: true, label: 'Label'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(fixture.onChangedCalls, isNotEmpty);
      expect(fixture.onChangedCalls.last, isTrue);
    });
  });
}


