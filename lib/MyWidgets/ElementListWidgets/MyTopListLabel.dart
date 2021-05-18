import 'package:flutter/material.dart';

class MyTopListLabel extends StatelessWidget {
  final String title;
  final String trailing;

  MyTopListLabel({@required this.title, @required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.blue[800],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            trailing: Text(
              trailing,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            dense: true,
          ),
        ),
      ),
    );
  }
}
