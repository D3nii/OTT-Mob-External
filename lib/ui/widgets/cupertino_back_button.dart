import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iPhone-style back button: chevron + label, matching Cupertino design.
class CupertinoBackButton extends StatelessWidget {
  const CupertinoBackButton({
    Key? key,
    required this.onPressed,
    this.label = 'Back',
    this.color,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? CupertinoColors.activeBlue;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      minSize: 0,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.back,
            size: 22,
            color: effectiveColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
