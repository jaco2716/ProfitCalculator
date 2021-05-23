import 'package:flutter/material.dart';

class MyTopListLabel extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function() sortByLeading;
  final void Function() sortByTrailing;

  MyTopListLabel({
    @required this.title,
    @required this.trailing,
    this.sortByLeading,
    this.sortByTrailing,
  });

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
            title: InkWell(
              onTap: sortByLeading,
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            trailing: InkWell(
              onTap: sortByTrailing,
              child: Text(
                trailing,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            dense: true,
          ),
        ),
      ),
    );
  }
}
