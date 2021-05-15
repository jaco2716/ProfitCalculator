import 'package:flutter/material.dart';

class MyLoadingCircle extends StatelessWidget {
  final double _height;
  MyLoadingCircle(this._height);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
