import 'package:flutter/material.dart';

class MyGridMenuButton extends StatelessWidget {
  final String title;
  final int index;
  final IconData icon;
  final void Function() onTap;
  final Color buttonColor;
  final Color contentColor;
  final bool round;
  MyGridMenuButton(
      {@required this.title,
      this.index,
      @required this.icon,
      @required this.onTap,
      this.buttonColor = Colors.white,
      this.contentColor = Colors.blue,
      this.round = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: round ? BorderRadius.circular(90) : BorderRadius.circular(20),
                ),
                shadowColor: Colors.grey[900],
                elevation: 10,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: contentColor,
                          size: 50,
                        ),
                        Padding(
                          padding: round ? const EdgeInsets.only(bottom: 12) : EdgeInsets.only(bottom: 5),
                          child: Text(title, style: TextStyle(color: contentColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          index != null
              ? Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(
                      '$index',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    radius: 11,
                  ),
                )
              : Center(),
        ],
      ),
    );
  }
}
