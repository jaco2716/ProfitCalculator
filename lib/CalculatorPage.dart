import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
// appBar: AppBar(title: Text('Calculator'),),
    return Container(
      // color: Colors.black,
      height: 350,
      child: Column(children: [
        Container(
          width: double.infinity,
          child: TextButton.icon(
              onPressed: () {
                // Navigator.of(context).pop();
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              },
              label: Text('Close'),
              icon: Icon(Icons.close)),
        ),
        Container(
          // color: Colors.blue,
          height: 300,
          child: SimpleCalculator(
            hideExpression: false,
            theme: const CalculatorThemeData(
              expressionStyle: TextStyle(fontSize: 15, height: 1,),
              displayColor: Colors.grey,
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
