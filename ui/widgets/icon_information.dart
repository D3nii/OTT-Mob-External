import 'package:flutter/material.dart';

class IconInformation extends StatelessWidget {
  const IconInformation(this.iconData, this.text, {Key? key}) : super(key: key);

  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
    child: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
              child: Icon(
            iconData,
            color: Color(0xffB9C4CE),
          )),
          Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Colors.black, fontWeight: FontWeight.normal, wordSpacing: 2, letterSpacing: 1),
            ),
          )
        ],
      ),
    ),
  );
  }
}
