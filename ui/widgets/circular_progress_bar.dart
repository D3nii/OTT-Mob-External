import 'package:flutter/material.dart';

class CircularProgressBar extends StatelessWidget {
  const CircularProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: Colors.black45,
          ),
          width: 100,
          height: 100,
          child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4.0,
              )
          )),
    );
  }
}
