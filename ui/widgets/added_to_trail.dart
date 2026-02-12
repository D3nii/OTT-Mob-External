import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/share/ui_helpers.dart';

class AddedToTrail extends StatelessWidget {
  const AddedToTrail(this.legend, {Key? key}) : super(key: key);

  final String legend;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.7),
              border: Border.all(
                color: Color.fromRGBO(0, 0, 0, 0.7),
              ),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UIHelper.horizontalSpace(24),
              Text(
                legend,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              UIHelper.horizontalSpace(32),
              ImageIcon(
                AssetImage("assets/icons/check.png"),
                color: Colors.white,
              ),
            ],
          )),
    );
  }
}
