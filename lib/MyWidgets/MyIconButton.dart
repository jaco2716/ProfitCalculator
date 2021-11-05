import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final Icon tileIcon;
  final Icon trailingIcon;
  final String tileTitle;
  final void Function() myOnPressed;
  final bool compact;
  final Color buttonColor;
  final Color contentColor;
  final double height;
  final bool leftalign;

  MyIconButton(
      {@required this.tileIcon,
      this.trailingIcon = const Icon(Icons.keyboard_arrow_right),
      @required this.tileTitle,
      @required this.myOnPressed,
      this.compact = false,
      this.leftalign = false,
      this.buttonColor = Colors.blue,
      this.contentColor = Colors.white,
      this.height = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: buttonColor,
          onPrimary: contentColor,
        ),
        onPressed: () => myOnPressed(),
        icon: tileIcon,
        label: compact
            ? leftalign
                ? Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(tileTitle),
                    width: double.infinity,
                  )
                : Text('$tileTitle')
            : Container(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(tileTitle),
                width: double.infinity,
              ),
        // label: compact
        //     ? leftalign ? Flexible(
        //         child: Padding(
        //           padding: const EdgeInsets.only(left: 10.0),
        //           child: Text('$tileTitle'),
        //         ),
        //         fit: FlexFit.tight,
        //       ) : Text('$tileTitle')
        //     : Flexible(
        //         fit: FlexFit.tight,
        //         child: Row(
        //           mainAxisSize: MainAxisSize.max,
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Padding(
        //               padding: const EdgeInsets.only(left: 10.0),
        //               child: Text('$tileTitle'),
        //             ),
        //             trailingIcon,
        //           ],
        //         ),
        //       ),
      ),
    );
  }
}
