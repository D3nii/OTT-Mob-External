import 'package:flutter/material.dart';
import 'components.dart';

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static late BuildContext _context;

  static set context(BuildContext context) {
    _context = context;
  }

  static void restart() {
    final state = _context.findAncestorStateOfType<_RestartWidgetState>();
    if (state != null) {
      state.restartApp();
      Components.restart();
    }
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
