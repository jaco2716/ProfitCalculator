import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final void Function() myOnPressed;
  final String confirmText;
  final Color confirmColor;
  final bool infoDialog;

  MyAlertDialog({
    @required this.title,
    @required this.content,
    @required this.cancelText,
    this.myOnPressed,
    this.confirmText = '',
    this.confirmColor = Colors.blue,
    this.infoDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 25)),
          child: Text(cancelText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        infoDialog
            ? null
            : ElevatedButton(
                child: Text(confirmText),
                style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 25)),
                onPressed: () => myOnPressed(),
              )
      ],
    );
  }
}
