import 'package:flutter/material.dart';

class SuccessToast extends StatelessWidget {
  const SuccessToast(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29.0),
        color: Color.fromRGBO(0, 0, 0, 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36.0,
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 36.0,
          ),
          ImageIcon(
            AssetImage("assets/icons/check.png"),
            size: 16,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
