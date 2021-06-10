import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyDeleteIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/ProfitMarginPercentageWidget.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/SingleElementExtraList.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/SingleElementPriceCard.dart';
import 'package:profit_calculator/Pages/MealPages/CreateMealPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class SingleMealPage extends StatefulWidget {
  final Meal meal;

  SingleMealPage(this.meal);

  @override
  _SingleMealPageState createState() => _SingleMealPageState();
}

class _SingleMealPageState extends State<SingleMealPage> {
  SharedValueHandler sharedVH = SharedValueHandler();
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  Meal meal;
  String _name;
  double _totalCost;
  double _salePrice;
  double _profitMargin;
  double _profit;
  List<Ingredient> _ingredients;
  int _vatPercent;
  int _hourPrice;

  @override
  void initState() {
    super.initState();
    meal = widget.meal;
  }

  @override
  Widget build(BuildContext context) {
    _name = meal.name;
    _salePrice = meal.salePrice;
    _ingredients = meal.ingredients;

    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                Meal newEditedMeal;
                newEditedMeal =
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateMealPage(editMode: true, editMeal: meal)));
                if (newEditedMeal != null) {
                  meal = newEditedMeal;
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
                  return MyLoadingCircle(500);
                }
                _vatPercent = vatSnapshot.data;
                return FutureBuilder(
                    future: _sharedValueHandler.getIntSharedP('hourPrice', 100),
                    builder: (context, hourPriceSnapshot) {
                      if (hourPriceSnapshot.connectionState == ConnectionState.waiting) {
                        return MyLoadingCircle(500);
                      }

                      return FutureBuilder(
                          future: _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK'),
                          initialData: '',
                          builder: (context, currencySnapshot) {
                            if (currencySnapshot.connectionState == ConnectionState.waiting) {
                              return MyLoadingCircle(500);
                            }

                            _hourPrice = hourPriceSnapshot.data;

                            _totalCost = meal.totalCost(_hourPrice);
                            _profit = meal.profit(_hourPrice, _vatPercent);
                            _profitMargin = meal.profitMargin(_hourPrice, _vatPercent);
                            return Column(
                              children: [
                                SingleElementPriceCard(
                                    'Total Cost:', null, '${_totalCost.toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.red),
                                SingleElementPriceCard('Net Price:', null,
                                    '${(_salePrice / (_vatPercent / 100 + 1)).toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.indigo),
                                SingleElementPriceCard('Sale Price:', '($_vatPercent% VAT)',
                                    '${(_salePrice).toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.blue),
                                SingleElementPriceCard('Profit:', null, '${_profit.toStringAsFixed(2)},- ${currencySnapshot.data}',
                                    _profitMargin > 0 ? Colors.green : Colors.orange),
                                _profitMargin < 0
                                    ? ProfitMarginPercentageWidget(-_profitMargin, Colors.orange[700], '-')
                                    : ProfitMarginPercentageWidget(_profitMargin, Colors.green[700], ''),
                                SingleElementExtraList(
                                    currencySnapshot.data,
                                    _ingredients
                                        ?.map<Map<String, dynamic>>((e) => {
                                              'title': e.name,
                                              'subtitle': '${e.amountInGrams.round()} ${e.measureUnit == 'Kg' ? 'g' : 'ml'}',
                                              'trailing': e.kgPrice * e.amountInGrams / 1000,
                                            })
                                        ?.toList(),
                                    'Ingredients'),
                                Card(
                                    margin: EdgeInsets.all(20),
                                    child: SingleElementExtraListTile('Time spent making meal.', '${meal.minutesToMake} min',
                                        '${((hourPriceSnapshot.data / 60) * meal.minutesToMake).toStringAsFixed(2)},- ${currencySnapshot.data}')),
                                MyDeleteIconButton(
                                  myOnPressed: () => _deleteMealDialog(context),
                                ),
                              ],
                            );
                          });
                    });
              })),
    );
  }

  _deleteMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: 'Delete',
          content: 'Are you sure you want to delete $_name?',
          cancelText: 'cancel',
          confirmText: 'Delete',
          myOnPressed: () => _deleteMeal(context),
        );
      },
    );
  }

  _deleteMeal(BuildContext context) async {
    bool deleteSuccess = false;

    deleteSuccess = await _deleteMealFromFile(meal);

    if (deleteSuccess) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
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

      String menuFileContent = await fileManagement.readFile(menuJsonFile);
      List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
      int mealFoundIndex = -1;
      if (allMenusFromFile != null) {
        for (var m in allMenusFromFile) {
          mealFoundIndex = m.meals.indexWhere((i) => i.id == meal.id);
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
            return MyAlertDialog(
              title: 'Error',
              content: 'Could not delete meal, because one or more menus are using it.',
              cancelText: 'Close',
              infoDialog: true,
            );
          },
        );
        return false;
      } else {
        int deleteIndex = allMeals.indexWhere((element) => element.id == newMeal.id);
        allMeals.removeAt(deleteIndex);
        fileManagement.writeFile(mealJsonFile, jsonEncode(allMeals));
      }
    } catch (error) {
      print('Error deleting meal: $error');
      return false;
    }
    return true;
  }
}
