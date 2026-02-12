import 'package:flutter/material.dart';

class DotsItem extends StatelessWidget {
  const DotsItem(
    this.isActive, {
    Key? key,
    this.mainColor = Colors.white,
  }) : super(key: key);

  final bool isActive;
  final Color mainColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      height: 9,
      width: 9,
      decoration: BoxDecoration(
        color: isActive ? mainColor : Colors.transparent,
        border: Border.all(width: isActive ? 0 : 2, color: isActive ? Colors.transparent : mainColor),
        borderRadius: BorderRadius.all(Radius.circular(9)),
      ),
    );
  }
}
