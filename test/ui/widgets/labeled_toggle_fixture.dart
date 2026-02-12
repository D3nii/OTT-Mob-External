import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/widgets/labeled_toggle.dart';

class LabeledToggleFixture {
  LabeledToggleFixture({bool initialValue = false})
      : value = ValueNotifier<bool>(initialValue);

  final ValueNotifier<bool> value;
  final List<bool> onChangedCalls = <bool>[];

  Widget build({bool enabled = true, String label = 'Label'}) {
    return MaterialApp(
      home: Material(
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: value,
            builder: (context, current, _) {
              return LabeledToggle(
                label: label,
                value: current,
                enabled: enabled,
                onChanged: (next) {
                  onChangedCalls.add(next);
                  value.value = next;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}


