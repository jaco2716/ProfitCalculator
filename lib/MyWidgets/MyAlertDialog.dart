import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final void Function() myOnPressed;
  final String confirmText;
  final Color confirmColor;
  final bool infoDialog;
  final Widget widgetContext;

  MyAlertDialog({
    @required this.title,
    @required this.content,
    @required this.cancelText,
    this.myOnPressed,
    this.confirmText = '',
    this.confirmColor = Colors.blue,
    this.infoDialog = false,
    this.widgetContext,
  });

  final TextStyle _titleText = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Container(
        child: Text(
          title,
          style: _titleText,
          textAlign: TextAlign.center,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: widgetContext == null
            ? Text(
                content,
                // style: _contentText,
                textAlign: TextAlign.center,
              )
            : widgetContext,
      ),
      actions: [
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      padding: EdgeInsets.all(12),
                    ),
                    child: Text(
                      cancelText,
                      // style: _whiteText,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              infoDialog
                  ? Center()
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.all(12),
                          ),
                          child: Text(
                            confirmText,
                            // style: _whiteText,
                          ),
                          onPressed: () => myOnPressed(),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
