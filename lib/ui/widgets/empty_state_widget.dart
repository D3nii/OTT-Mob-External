import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget(this.legend, {Key? key}) : super(key: key);

  final String legend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.only(top: 23, left: 30, right: 30, bottom: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.sync_problem, size: 64.0, color: Color(0xff9e9e9b)),
          UIHelper.verticalSpace(32.0),
          Text(
            legend,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Roboto-Medium", fontSize: 16, color: Color(0xff9e9e9b), fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
