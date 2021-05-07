import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/MealPages/CreateMeal.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Model/Extra.dart';
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
  int _vatPercent = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isMeal) {
      _name = widget.meal.name;
      _salePrice = widget.meal.salePrice;
      _ingredients = widget.meal.ingredients;
    } else {
      _name = widget.menu.name;
      _salePrice = widget.menu.salePrice;
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
              future: _sharedValueHandler.getIntSharedP('VATPercent', 25),
              builder: (context, vatSnapshot) {
                if (vatSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()));
                }
                _vatPercent = vatSnapshot.data;
                return FutureBuilder(
                    future: _sharedValueHandler.getIntSharedP('hourPrice', 100),
                    builder: (context, hourPriceSnapshot) {
                      if (hourPriceSnapshot.connectionState ==
                          ConnectionState.waiting)
                        return CircularProgressIndicator();
                      return FutureBuilder(
                          future: _sharedValueHandler.getStringSharedP(
                              'CurrencyChosen', 'DKK'),
                          initialData: '',
                          builder: (context, currencySnapshot) {
                            if (currencySnapshot.connectionState ==
                                ConnectionState.waiting)
                              return CircularProgressIndicator();
                            int _hourPrice = hourPriceSnapshot.data;
                            if (widget.isMeal) {
                              _totalCost = widget.meal.totalCost(_hourPrice);
                              _profit = widget.meal.profit(_hourPrice, _vatPercent);
                              _profitMargin =
                                  widget.meal.profitMargin(_hourPrice, _vatPercent);
                            } else {
                              _totalCost = widget.menu.totalCost(_hourPrice);
                              _profit = widget.menu.profit(_hourPrice, _vatPercent);
                              _profitMargin = widget.menu
                                  .profitMargin(_hourPrice, _vatPercent);
                            }
                            return Column(
                              children: [
                                Card(
                                  color: Colors.red[50],
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 5),
                                  child: Container(
                                      width: double.infinity,
                                      child: ListTile(
                                        title: Text(
                                          'Total Cost:',
                                          style:
                                              TextStyle(color: Colors.red[700]),
                                        ),
                                        trailing: Text(
                                          '${_totalCost.toStringAsFixed(2)},- ${currencySnapshot.data}',
                                          style:
                                              TextStyle(color: Colors.red[700]),
                                        ),
                                      )),
                                ),
                                Card(
                                  color: Colors.indigo[50],
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 5),
                                  child: Container(
                                      width: double.infinity,
                                      child: ListTile(
                                        title: Text(
                                          'Net Price:',
                                          style: TextStyle(
                                              color: Colors.blue[700]),
                                        ),
                                        trailing: Text(
                                          '${(_salePrice / (_vatPercent / 100 + 1)).toStringAsFixed(2)},- ${currencySnapshot.data}',
                                          style: TextStyle(
                                              color: Colors.blue[700]),
                                        ),
                                      )),
                                ),
                                Card(
                                  color: Colors.blue[50],
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 5),
                                  child: Container(
                                    width: double.infinity,
                                    child: ListTile(
                                      dense: true,
                                        title: Text(
                                          'Sale Price:',
                                          style: TextStyle(
                                            fontSize: 16,
                                              color: Colors.blue[700]),
                                        ),
                                        subtitle: Text(
                                          '($_vatPercent% VAT):',
                                          style: TextStyle(
                                              color: Colors.blue[700]),
                                        ),
                                        trailing: Text(
                                          '${(_salePrice).toStringAsFixed(2)},- ${currencySnapshot.data}',
                                          style: TextStyle(
                                              color: Colors.blue[700]),
                                        )),
                                  ),
                                ),
                                Card(
                                  elevation: 5,
                                  color: _profitMargin > 0
                                      ? Colors.green[50]
                                      : Colors.orange[50],
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 5),
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
                                // RaisedButton(
                                //     child: Text('Choose Profit Margin'),
                                //     onPressed: () {
                                //       _showChangeProfitMargin(context);
                                //     }),

                                ingredientList(
                                    currencySnapshot.data, _ingredients),

                                !widget.isMeal
                                    ? mealList(currencySnapshot.data,
                                        widget.menu.meals, _hourPrice)
                                    : Card(
                                        margin: EdgeInsets.all(20),
                                        child: ListTile(
                                          title: Text(
                                              'Time spent making meal.'), //'Cost for time spend\nmaking meal.'
                                          subtitle: Text(
                                              ' - ${widget.meal.minutesToMake} min'),
                                          trailing: Text(
                                              '${((hourPriceSnapshot.data / 60) * widget.meal.minutesToMake).toStringAsFixed(2)},- ${currencySnapshot.data}'),
                                        ),
                                      ),

                                !widget.isMeal
                                    ? extraList(currencySnapshot.data,
                                        widget.menu.extras)
                                    : Center(),

                                Container(
                                  padding: EdgeInsets.all(20),
                                  width: 200,
                                  child: IconButton(
                                      iconSize: 40,
                                      color: Colors.red,
                                      icon: Icon(Icons.delete),
                                      padding: EdgeInsets.all(15),
                                      onPressed: () =>
                                          _deleteMealDialog(context)),
                                ),
                              ],
                            );
                          });
                    });
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

  Widget mealList(String currencyString, List<Meal> _iMeals, int _iHourPrice) {
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
          _iMeals.length == 0
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text('No meals added.'),
                )
              : ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: _iMeals.length,
                  itemBuilder: (BuildContext context, int index) {
                    double _iTotalPrice;
                    _iTotalPrice = _iMeals[index].totalCost(_iHourPrice) *
                        _iMeals[index].amount;

                    return ListTile(
                      title: Text(_iMeals[index].name),
                      subtitle: Text(' - x${_iMeals[index].amount} '),
                      trailing: Text(
                          '${_iTotalPrice.toStringAsFixed(2)} ,- $currencyString'),
                    );
                  },
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
        ],
      ),
    );
  }

  Widget extraList(String currencyString, List<Extra> _iExtra) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Extras',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 22,
                  color: Colors.pink[200],
                )),
          ),
          Divider(
            thickness: 1,
          ),
          _iExtra.length == 0
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text('No extras added.'),
                )
              : ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: _iExtra.length,
                  itemBuilder: (BuildContext context, int index) {
                    double _iTotalPrice =
                        _iExtra[index].costPrice * _iExtra[index].amount;

                    return ListTile(
                      title: Text(_iExtra[index].name),
                      subtitle: Text(' - x${_iExtra[index].amount} '),
                      trailing: Text(
                          '${_iTotalPrice.toStringAsFixed(2)} ,- $currencyString'),
                    );
                  },
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
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

    if (widget.isMeal) {
      deleteSuccess = await _deleteMealFromFile(widget.meal);
    } else {
      deleteSuccess = await _deleteMenuFromFile(widget.menu);
    }

    if (deleteSuccess) {
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(
      //       builder: (context) => MyHomePage(),
      //     ),
      //     (route) => false);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_name} was deleted.'),
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

      String menuFileContent = await fileManagement.readFile(menuJsonFile);
      List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
      int mealFoundIndex = -1;
      if (allMenusFromFile != null) {
        for (var m in allMenusFromFile) {
          mealFoundIndex = m.meals.indexWhere((i) => i.id == widget.meal.id);
          if (mealFoundIndex >= 0) {
            break;
          }
        }
      }

      if (mealFoundIndex != -1) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Could not delete ingredient, because one or more meals are using it.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok'))
              ],
            );
          },
        );
        return false;
      } else {
        int deleteIndex =
            allMeals.indexWhere((element) => element.id == newMeal.id);
        allMeals.removeAt(deleteIndex);
        fileManagement.writeFile(mealJsonFile, jsonEncode(allMeals));
      }
    } catch (error) {
      print('Error deleting meal: $error');
      return false;
    }
    return true;
  }

  Future<bool> _deleteMenuFromFile(Menu newMenu) async {
    try {
      String fileContent = await fileManagement.readFile(menuJsonFile);
      List<Menu> allMenus = objManager.jsonToListMenu(fileContent);
      int deleteIndex =
          allMenus.indexWhere((element) => element.id == newMenu.id);
      allMenus.removeAt(deleteIndex);
      fileManagement.writeFile(menuJsonFile, jsonEncode(allMenus));
    } catch (error) {
      print('Error deleting menu: $error');
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
          Text('Profit'),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.blue[100],
      progressColor: indicatorColor,
    );
  }
}
