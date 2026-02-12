import 'package:flutter/material.dart';

class AddToggleButton extends StatelessWidget {
  const AddToggleButton(this.isAdded, this.onTap, {Key? key}) : super(key: key);

  final bool isAdded;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 22,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: isAdded ? Color.fromRGBO(220, 84, 102, 0.7) : Color.fromRGBO(0, 170, 153, 0.7),
          child: ImageIcon(
            AssetImage(isAdded ? "assets/icons/icon_minus.png" : "assets/icons/icon_plus.png"),
            size: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
