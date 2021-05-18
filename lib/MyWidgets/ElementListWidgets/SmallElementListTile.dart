import 'package:flutter/material.dart';

class SmallElementListTile extends StatelessWidget {
  // Element has: title, trailing
  final Map<String, dynamic> element;
  final void Function() myOnPressed;

  SmallElementListTile({
    @required this.element,
    @required this.myOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ListTile(
contentPadding: EdgeInsets.only(right: 8,left: 20, top: 6, bottom: 6),
            title: Text(element['title']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(element['trailing']),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 18,
                  ),
                )
              ],
            ),
            onTap: () => myOnPressed()),
      ),
    );
  }
}
