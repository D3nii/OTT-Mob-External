import 'package:flutter/material.dart';

import 'package:onetwotrail/ui/share/app_colors.dart';



class SplashView extends StatelessWidget {
  final Image image;

  const SplashView({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    child: Scaffold(
      backgroundColor: pinkish,
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: image.image, fit: BoxFit.fill),
          ),
          child: null),
    ),
  );
}
}
