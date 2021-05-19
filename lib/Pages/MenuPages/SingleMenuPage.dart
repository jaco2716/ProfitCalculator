import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/ProfitMarginPercentageWidget.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/SingleElementExtraList.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/SingleElementPriceCard.dart';
import 'package:profit_calculator/Pages/MealPages/CreateMeal.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class SingleMenuPage extends StatefulWidget {
  Menu menu;
  SingleMenuPage(this.menu);

  @override
  _SingleMenuPageState createState() => _SingleMenuPageState();
}

class _SingleMenuPageState extends State<SingleMenuPage> {
  SharedValueHandler sharedValueHandler = SharedValueHandler();
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
  int _vatPercent;
  int _hourPrice;

  @override
  Widget build(BuildContext context) {
    _name = widget.menu.name;
    _salePrice = widget.menu.salePrice;
    _ingredients = widget.menu.ingredients;
    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
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
                      if (hourPriceSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return MyLoadingCircle(500);
                      }

                      return FutureBuilder(
                          future: _sharedValueHandler.getStringSharedP(
                              'CurrencyChosen', 'DKK'),
                          initialData: '',
                          builder: (context, currencySnapshot) {
                            if (currencySnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return MyLoadingCircle(500);
                            }

                            _hourPrice = hourPriceSnapshot.data;
                            _totalCost = widget.menu.totalCost(_hourPrice);
                            _profit =
                                widget.menu.profit(_hourPrice, _vatPercent);
                            _profitMargin = widget.menu
                                .profitMargin(_hourPrice, _vatPercent);
                            // }
                            return Column(
                              children: [
                                SingleElementPriceCard(
                                    'Total Cost:',
                                    null,
                                    '${_totalCost.toStringAsFixed(2)},- ${currencySnapshot.data}',
                                    Colors.red),
                                SingleElementPriceCard(
                                    'Net Price:',
                                    null,
                                    '${(_salePrice / (_vatPercent / 100 + 1)).toStringAsFixed(2)},- ${currencySnapshot.data}',
                                    Colors.indigo),
                                SingleElementPriceCard(
                                    'Sale Price:',
                                    '($_vatPercent% VAT)',
                                    '${(_salePrice).toStringAsFixed(2)},- ${currencySnapshot.data}',
                                    Colors.blue),
                                SingleElementPriceCard(
                                    'Profit:',
                                    null,
                                    '${_profit.toStringAsFixed(2)},- ${currencySnapshot.data}',
                                    _profitMargin > 0
                                        ? Colors.green
                                        : Colors.orange),
                                _profitMargin < 0
                                    ? ProfitMarginPercentageWidget(
                                        -_profitMargin, Colors.orange[700], '-')
                                    : ProfitMarginPercentageWidget(
                                        _profitMargin, Colors.green[700], ''),
                                SingleElementExtraList(
                                    currencySnapshot.data,
                                    _ingredients
                                        ?.map<Map<String, dynamic>>((e) => {
                                              'title': e.name,
                                              'subtitle':
                                                  '${e.amountInGrams.round()} ${e.measureUnit == 'Kg' ? 'g' : 'ml'}',
                                              'trailing': e.kgPrice *
                                                  e.amountInGrams /
                                                  1000,
                                            })
                                        ?.toList(),
                                    'Ingredients'),
                                SingleElementExtraList(
                                    currencySnapshot.data,
                                    widget.menu.meals
                                        ?.map<Map<String, dynamic>>((e) => {
                                              'title': e.name,
                                              'subtitle': 'x${e.amount}',
                                              'trailing':
                                                  e.totalCost(_hourPrice) *
                                                      e.amount,
                                            })
                                        ?.toList(),
                                    'Ingredients'),
                                SingleElementExtraList(
                                    currencySnapshot.data,
                                    widget.menu.extras
                                        ?.map<Map<String, dynamic>>((e) => {
                                              'title': e.name,
                                              'subtitle': 'x${e.amount}',
                                              'trailing':
                                                  e.costPrice * e.amount,
                                            })
                                        ?.toList(),
                                    'Extras'),
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

    deleteSuccess = await _deleteMenuFromFile(widget.menu);

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
}
