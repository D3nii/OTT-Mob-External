import 'package:flutter/material.dart';

class PlaceholderScrollableView extends StatelessWidget {
  const PlaceholderScrollableView({
    Key? key,
    required this.title,
    required this.scrollController,
  }) : super(key: key);

  final String title;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: PageStorageKey<String>(title),
      controller: scrollController,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                color: Colors.black12,
                height: 700,
                child: Center(
                  child: Text(title),
                ),
              ),
              Container(color: Colors.black12, height: 500),
              Container(color: Colors.black26, height: 500),
              Container(color: Colors.black38, height: 500),
              Container(color: Colors.black26, height: 500),
              Container(color: Colors.black12, height: 500),
              Container(color: Colors.black26, height: 500),
              Container(color: Colors.black38, height: 500),
            ],
          ),
        ),
      ),
    );
  }
}
