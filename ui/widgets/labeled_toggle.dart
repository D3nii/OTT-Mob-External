import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';

class LabeledToggle extends StatelessWidget {
  const LabeledToggle({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        Semantics(
          label: label,
          toggled: value,
          enabled: enabled,
          child: Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: Colors.white,
            activeTrackColor: tealish,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}


