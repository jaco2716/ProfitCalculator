import 'package:flutter/material.dart';
import 'package:profit_calculator/IngredientPages/CreateIngredient.dart';
import 'package:profit_calculator/MealPages/CreateMeal.dart';

class InitialFutureWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: 100),
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
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateIngredient()));
          },
        ),
      ),
      SizedBox(height: 10),
      Container(
        width: 200,
        child: RaisedButton.icon(
          padding: EdgeInsets.all(10),
          icon: Icon(Icons.add),
          label: Text('Create Meal'),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CreateMeal()));
          },
        ),
      ),
      SizedBox(height: 200),
    ]);
  }
}
