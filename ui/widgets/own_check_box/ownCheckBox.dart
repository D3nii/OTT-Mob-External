import 'package:flutter/material.dart';
import 'package:onetwotrail/ui/share/app_colors.dart';

class OwnCheckBox extends StatelessWidget {
  const OwnCheckBox(this.check, this.isSelected, {Key? key}) : super(key: key);

  final Function(bool active) check;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return isSelected
      ? Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: tealish,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0)),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
            onTap: () {
              check(false);
            },
          ),
        )
      : Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      topLeft: Radius.circular(5.0)),
                  border: Border.all(color: tealish, width: 2)),
            ),
            onTap: () {
              check(true);
            },
          ),
        );
  }
}
