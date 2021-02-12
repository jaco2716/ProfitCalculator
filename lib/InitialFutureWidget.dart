import 'package:flutter/material.dart';

class InitialFutureWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Icon(
          Icons.emoji_people_rounded,
          size: 80,
          color: Colors.blue[100],
        ),
      ),
      Text(
        "Get started!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30, color: Colors.grey),
      ),
      SizedBox(height: 20),
      Container(
        width: 200,
        child: RaisedButton.icon(
          padding: EdgeInsets.all(10),
          icon: Icon(Icons.add),
          label: Text('Create Ingredient'),
          onPressed: () {},
        ),
      ),
      SizedBox(height: 10),
      Container(
        width: 200,
        child: RaisedButton.icon(
          padding: EdgeInsets.all(10),
          icon: Icon(Icons.add),
          label: Text('Create Meal'),
          onPressed: () {},
        ),
      ),
      SizedBox(height: 200),
    ]);
  }
}
