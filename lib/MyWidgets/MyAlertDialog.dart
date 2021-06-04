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

  final TextStyle _whiteText = TextStyle(color: Colors.black);
  final TextStyle _titleText = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white70);
  final TextStyle _contentText = TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    double buttonSideRadius = infoDialog ? 30 : 0;
    return AlertDialog(
      // backgroundColor: Colors.blue,
      buttonPadding: EdgeInsets.all(0),
      insetPadding: EdgeInsets.all(25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      titlePadding: EdgeInsets.all(0),
      title: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          color: Colors.blue,
        ),
        child: Text(
          title,
          style: _titleText,
          textAlign: TextAlign.center,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          content,
          // style: _contentText,
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            // topLeft: Radius.circular(40),
                            bottomLeft: Radius.circular(30),
                            // topRight: Radius.circular(buttonSideRadius),
                            bottomRight: Radius.circular(buttonSideRadius))),
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
              infoDialog
                  ? Center()
                  : Expanded(
                      child: ElevatedButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            // topRight: Radius.circular(40),
                            bottomRight: Radius.circular(30),
                          )),
                        ),
                        child: Text(
                          confirmText,
                          // style: _whiteText,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
            ],
          ),
        ),
        // infoDialog
        //     ? Center()
        //     : ElevatedButton(
        //         child: Text(
        //           confirmText,
        //           // style: _whiteText,
        //         ),
        //         style: ElevatedButton.styleFrom(primary: Colors.red, padding: EdgeInsets.symmetric(horizontal: 25)),
        //         onPressed: () => myOnPressed(),
        //       )
      ],
    );
  }
}
