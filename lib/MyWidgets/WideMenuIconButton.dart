import 'package:flutter/material.dart';

class WideMenuIconButton extends StatelessWidget {
  final Icon tileIcon;
  final String tileTitle;
  final void Function() myOnPressed;

  WideMenuIconButton({this.tileIcon, this.tileTitle, this.myOnPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Theme(
        data: ThemeData.dark(),
        child: Card(
          color: Colors.blue,
          child: ListTile(
              leading: tileIcon,
              title: Text(tileTitle),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                myOnPressed();
                // Navigator.pop(context);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => navigationPage));
              }),
        ),
      ),
    );
  }
}
