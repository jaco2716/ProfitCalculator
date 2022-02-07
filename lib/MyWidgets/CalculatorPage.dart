import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class CalculatorWidget extends StatelessWidget {
  const CalculatorWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
// appBar: AppBar(title: Text('Calculator'),),
    return Container(
      height: 345,
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
          color: Colors.grey[800],
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          // width: double.infinity,
          height: 45,
          child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              },
              // label: Text('Close'),
              icon: Icon(Icons.close, color: Colors.white,)),
        ),
        Container(
          padding: EdgeInsets.all(5),
          color: Colors.grey[800],
          height: 300,
          child: SimpleCalculator(
            hideExpression: false,
            theme: const CalculatorThemeData(
              expressionStyle: TextStyle(
                fontSize: 15,
                height: 1,
              ),
              displayColor: Colors.black,
              displayStyle: const TextStyle(fontSize: 80, color: Colors.white),
              numStyle: TextStyle(fontSize: 25, color: Colors.black),
              commandStyle: TextStyle(fontSize: 20, color: Colors.white),
              /*...*/
            ),
          ),
        ),
      ]),
    );
  }
  // );
  // }
}
