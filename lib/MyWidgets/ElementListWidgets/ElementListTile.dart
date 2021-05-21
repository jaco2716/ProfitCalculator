import 'package:flutter/material.dart';

class ElementListTile extends StatelessWidget {
  // Element has: String title, String subtitle, double trailing1, int trailing2
  final Map<String, dynamic> element;
  final void Function() myOnPressed;

  ElementListTile({
    @required this.element,
    @required this.myOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    double trailing1 = element['trailing1'];
    int trailing2 = element['trailing2'];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Text(element['title']),
          subtitle:
              element['subtitle'] != null ? Text(element['subtitle']) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${trailing1.toStringAsFixed(2)},-',
                style: TextStyle(color: Colors.blue),
              ),
              Text(' / '),
              Text(
                '$trailing2%',
                style: TextStyle(
                    color: trailing2 > 0 ? Colors.green : Colors.orange[700]),
              ),
            ],
          ),
          onTap: () => myOnPressed()),
    );
  }
}
