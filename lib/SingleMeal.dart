import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/CreateMeal.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:profit_calculator/FileManagement.dart';
import 'package:profit_calculator/ObjectManager.dart';
import 'Model/EnvironmentConfig.dart' as config;
import 'Model/Meal.dart';
import 'main.dart';

class SingleMeal extends StatefulWidget {
  String title;
  Meal meal;

  SingleMeal(this.title, this.meal);

  @override
  _SingleMealState createState() => _SingleMealState();
}

class _SingleMealState extends State<SingleMeal> {
  final FileManagement fileManagement = FileManagement();

  final ObjectManager objManager = ObjectManager();

  String mealJsonFile = config.mealJsonFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) =>
                            CreateMeal(editMode: true, editMeal: widget.meal)))
                    .then((context) {
                  setState(() {});
                });
              })
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Card(
            color: Colors.red[50],
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            child: Container(
                width: double.infinity,
                child: ListTile(
                  title: Text(
                    'Total Cost:',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  trailing: Text(
                    '${widget.meal.totalCost.toStringAsFixed(2)},- kr',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                )),
          ),
          Card(
            color: Colors.blue[50],
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            child: Container(
                width: double.infinity,
                child: ListTile(
                  title: Text(
                    'Sale Price:',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  trailing: Text(
                    '${widget.meal.salePrice.toStringAsFixed(2)},- kr',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                )),
          ),
          Card(
            elevation: 5,
            color: widget.meal.profitMargin > 0
                ? Colors.green[50]
                : Colors.orange[50],
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            child: Container(
                width: double.infinity,
                child: ListTile(
                  title: Text(
                    'Profit:',
                    style: TextStyle(
                        color: widget.meal.profitMargin > 0
                            ? Colors.green[700]
                            : Colors.orange[700]),
                  ),
                  trailing: Text(
                    '${widget.meal.profit.toStringAsFixed(2)},- kr',
                    style: TextStyle(
                        color: widget.meal.profitMargin > 0
                            ? Colors.green[700]
                            : Colors.orange[700]),
                  ),
                )),
          ),
          widget.meal.profitMargin < 0
              ? _profitMarginWidget(
                  -widget.meal.profitMargin, Colors.orange[700], '-')
              : _profitMarginWidget(
                  widget.meal.profitMargin, Colors.green[700], ''),
          // RaisedButton(
          //     child: Text('Choose Profit Margin'),
          //     onPressed: () {
          //       _showChangeProfitMargin(context);
          //     }),
          Card(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Ingredients',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 30,
                        color: Colors.pink[100],
                      )),
                ),
                Divider(
                  thickness: 1,
                ),
                ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: widget.meal.ingredients.length,
                  itemBuilder: (BuildContext context, int index) {
                    String _lowMeasureUnit =
                        widget.meal.ingredients[index].measureUnit == 'Kg'
                            ? 'g'
                            : 'ml';
                    // print(Color(meal.ingredients[index].color));
                    return ListTile(
                      title: Row(children: [
                        CircleAvatar(
                          backgroundColor:
                              Color(widget.meal.ingredients[index].color),
                          radius: 10,
                        ),
                        Text('   ' + widget.meal.ingredients[index].name),
                      ]),
                      subtitle: Text(
                          '         ${widget.meal.ingredients[index].amountInGrams.round()} ' +
                              _lowMeasureUnit),
                      trailing: Text(
                          '${(widget.meal.ingredients[index].kgPrice * widget.meal.ingredients[index].amountInGrams / 1000).toStringAsFixed(2)} kr,-'),
                    );
                  },
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: 200,
            child: IconButton(
                iconSize: 40,
                color: Colors.red,
                icon: Icon(Icons.delete),
                padding: EdgeInsets.all(15),
                onPressed: () => _deleteMealDialog(context)),
          ),
        ],
      )),
    );
  }

  _deleteMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Are you sure you want to delete ${widget.meal.name}?'),
          actions: [
            FlatButton(
              child: Text('cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text('Delete'),
              color: Colors.red,
              onPressed: () => _deleteMeal(context),
            )
          ],
        );
      },
    );
  }

  _deleteMeal(BuildContext context) async {
    bool deleteSuccess = false;

    deleteSuccess = await _deleteMealFromFile(widget.meal);

    if (deleteSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
          (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.meal.name} was deleted.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong, please try again.'),
      ));
    }
  }

  Future<bool> _deleteMealFromFile(Meal newMeal) async {
    try {
      String fileContent = await fileManagement.readFile(mealJsonFile);
      List<Meal> allMeals = objManager.jsonToListMeal(fileContent);
      int deleteIndex =
          allMeals.indexWhere((element) => element.id == newMeal.id);
      allMeals.removeAt(deleteIndex);
      fileManagement.writeFile(mealJsonFile, jsonEncode(allMeals));
    } catch (error) {
      print('Error deleting meal: $error');
      return false;
    }
    return true;
  }

  Widget _profitMarginWidget(
      double localProfitMargin, Color indicatorColor, String negative) {
    localProfitMargin /= 100;
    return CircularPercentIndicator(
      radius: 170.0,
      lineWidth: 20.0,
      animation: true,
      percent: localProfitMargin < 1 ? localProfitMargin : 1,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Text(
            "$negative${(localProfitMargin * 100).round()}%",
            textAlign: TextAlign.center,
            style: new TextStyle(fontWeight: FontWeight.w300, fontSize: 30.0),
          ),
          Text('Profit Margin'),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.blue[100],
      progressColor: indicatorColor,
    );
  }
}
