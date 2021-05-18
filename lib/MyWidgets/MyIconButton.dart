import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final Icon tileIcon;
  final Icon trailingIcon;
  final String tileTitle;
  final void Function() myOnPressed;
  final bool compact;
  final Color buttonColor;
  final Color contentColor;

  MyIconButton({
    @required this.tileIcon,
    this.trailingIcon = const Icon(Icons.keyboard_arrow_right),
    @required this.tileTitle,
    @required this.myOnPressed,
    this.compact = false,
    this.buttonColor = Colors.blue,
    this.contentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          onPrimary: contentColor,
        ),
        onPressed: () => myOnPressed(),
        icon: tileIcon,
        label: compact
            ? Text(tileTitle)
            : Container(
                width: 240,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text('$tileTitle'),
                    ),
                    trailingIcon,
                  ],
                ),
              ),
      ),
    );
  }
}
