import 'package:flutter/material.dart';

class MyDeleteIconButton extends StatelessWidget {
  final void Function() myOnPressed;
  MyDeleteIconButton({@required this.myOnPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(40),
      iconSize: 40,
      color: Colors.red,
      icon: Icon(Icons.delete),
      onPressed: () => myOnPressed(),
    );
  }
}
