import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/MealPages/CreateMeal.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Menu.dart';
import '../Model/EnvironmentConfig.dart' as config;
import '../Model/Meal.dart';
import '../main.dart';

class SingleMeal extends StatefulWidget {
  Meal meal;
  Menu menu;
  bool isMeal;

  SingleMeal({this.meal, this.menu, this.isMeal});

  @override
  _SingleMealState createState() => _SingleMealState();
}

class _SingleMealState extends State<SingleMeal> {
  SharedValueHandler sharedVH = SharedValueHandler();
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  String _name;
  double _totalCost;
  double _salePrice;
  double _profitMargin;
  double _profit;
  List<Ingredient> _ingredients;

  @override
  Widget build(BuildContext context) {
    if (widget.isMeal) {
      _name = widget.meal.name;
      _totalCost = widget.meal.totalCost;
      _salePrice = widget.meal.salePrice;
      _profitMargin = widget.meal.profitMargin;
      _profit = widget.meal.profit;
      _ingredients = widget.meal.ingredients;
    } else {
      _name = widget.menu.name;
      _totalCost = widget.menu.totalCost;
      _salePrice = widget.menu.salePrice;
      _profitMargin = widget.menu.profitMargin;
      _profit = widget.menu.profit;
      _ingredients = widget.menu.ingredients;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                if (widget.isMeal) {
                  Meal newEditedMeal;
                  newEditedMeal = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => CreateMeal(
                              editMode: true,
                              editMeal: widget.meal,
                              isMeals: true)));
                  if (newEditedMeal != null) {
                    widget.meal = newEditedMeal;
                  }
                } else {
                  Menu newEditedMenu;
                  newEditedMenu = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => CreateMeal(
                              editMode: true,
                              editMenu: widget.menu,
                              isMeals: false)));
                  if (newEditedMenu != null) {
                    widget.menu = newEditedMenu;
                  }
                }
                setState(() {});
              })
        ],
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
              future:
                  _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK'),
              initialData: '',
              builder: (context, currencySnapshot) {
                return Column(
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
                              '${_totalCost.toStringAsFixed(2)},- ${currencySnapshot.data}',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          )),
                    ),
                    Card(
                      color: Colors.indigo[50],
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                      child: Container(
                          width: double.infinity,
                          child: ListTile(
                            title: Text(
                              'Net Price:',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                            trailing: Text(
                              '${_salePrice.toStringAsFixed(2)},- ${currencySnapshot.data}',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          )),
                    ),
                    Card(
                      color: Colors.blue[50],
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                      child: Container(
                          width: double.infinity,
                          child: FutureBuilder(
                              future: sharedVH.getIntSharedP('VATPercent', 25),
                              initialData: 0,
                              builder: (context, snapshot) {
                                return ListTile(
                                    title: Text(
                                      'Gross Price (${snapshot.data}% VAT):',
                                      style: TextStyle(color: Colors.blue[700]),
                                    ),
                                    trailing: Text(
                                      '${(_salePrice * (snapshot.data / 100 + 1)).toStringAsFixed(2)},- ${currencySnapshot.data}',
                                      style: TextStyle(color: Colors.blue[700]),
                                    ));
                              })),
                    ),
                    Card(
                      elevation: 5,
                      color: _profitMargin > 0
                          ? Colors.green[50]
                          : Colors.orange[50],
                      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                      child: Container(
                          width: double.infinity,
                          child: ListTile(
                            title: Text(
                              'Profit:',
                              style: TextStyle(
                                  color: _profitMargin > 0
                                      ? Colors.green[700]
                                      : Colors.orange[700]),
                            ),
                            trailing: Text(
                              '${_profit.toStringAsFixed(2)},- ${currencySnapshot.data}',
                              style: TextStyle(
                                  color: _profitMargin > 0
                                      ? Colors.green[700]
                                      : Colors.orange[700]),
                            ),
                          )),
                    ),
                    _profitMargin < 0
                        ? _profitMarginWidget(
                            -_profitMargin, Colors.orange[700], '-')
                        : _profitMarginWidget(
                            _profitMargin, Colors.green[700], ''),
                    ingredientList(currencySnapshot.data, _ingredients),
                    !widget.isMeal
                        ? mealList(currencySnapshot.data, widget.menu.meals)
                        : Center(),
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
                );
              })),
    );
  }

  Widget ingredientList(String currencyString, List<Ingredient> _iIngredients) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Ingredients',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 22,
                  color: Colors.pink[200],
                )),
          ),
          Divider(
            thickness: 1,
          ),
          _iIngredients.length == 0
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text('No ingredients added.'),
                )
              : ListView.separated(
                  padding: EdgeInsets.only(bottom: 15),
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: _iIngredients.length,
                  itemBuilder: (BuildContext context, int index) {
                    double dividerDouble =
                        _iIngredients[index].measureUnit == 'Kg' ||
                                _iIngredients[index].measureUnit == 'Liter'
                            ? 1000
                            : 1;
                    String _lowMeasureUnit =
                        _iIngredients[index].measureUnit == 'Kg' ? 'g' : 'ml';
                    print(_iIngredients.toString());

                    return ListTile(
                      title: Text(_iIngredients[index].name),
                      subtitle: Text(
                          ' - ${_iIngredients[index].amountInGrams.round()} ' +
                              _lowMeasureUnit),
                      trailing: Text(
                          '${(_iIngredients[index].kgPrice * _iIngredients[index].amountInGrams / dividerDouble).toStringAsFixed(2)},- $currencyString'),
                    );
                  },
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                )
        ],
      ),
    );
  }

  Widget mealList(String currencyString, List<Meal> _iMeal) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Meals',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 22,
                  color: Colors.pink[200],
                )),
          ),
          Divider(
            thickness: 1,
          ),
          _iMeal.length == 0
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text('No meals added.'),
                )
              : ListView.separated(
                  padding: EdgeInsets.only(bottom: 15),
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: _iMeal.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_iMeal[index].name),
                      subtitle: Text(' - x${_iMeal[index].amount} '),
                      trailing: Text(
                          '${(_iMeal[index].totalCost * _iMeal[index].amount).toStringAsFixed(2)},- $currencyString'),
                    );
                  },
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                )
        ],
      ),
    );
  }

  _deleteMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Are you sure you want to delete ${_name}?'),
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
        content: Text('$_name was deleted.'),
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
