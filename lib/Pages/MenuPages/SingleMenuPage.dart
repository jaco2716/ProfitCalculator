import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyDeleteIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/ProfitMarginPercentageWidget.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/SingleElementExtraList.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/SingleElementPriceCard.dart';
import 'package:profit_calculator/Pages/MenuPages/CreateMenuPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class SingleMenuPage extends StatefulWidget {
  final Menu menu;
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
  Menu menu;
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
    menu = widget.menu;
  }

  @override
  Widget build(BuildContext context) {
    _name = menu.name;
    _salePrice = menu.salePrice;
    _ingredients = menu.ingredients;
    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                Menu newEditedMenu;
                newEditedMenu =
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateMenuPage(editMode: true, editMenu: menu)));
                if (newEditedMenu != null) {
                  menu = newEditedMenu;
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
                          _totalCost = menu.totalCost(_hourPrice);
                          _profit = menu.profit(_hourPrice, _vatPercent);
                          _profitMargin = menu.profitMargin(_hourPrice, _vatPercent);
                          // }
                          return Column(
                            children: [
                              SingleElementPriceCard('Total Cost:', null, '${_totalCost.toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.red),
                              SingleElementPriceCard('Net Price:', null,
                                  '${(_salePrice / (_vatPercent / 100 + 1)).toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.indigo),
                              SingleElementPriceCard(
                                  'Sale Price:', '($_vatPercent% VAT)', '${(_salePrice).toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.blue),
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
                              SingleElementExtraList(
                                  currencySnapshot.data,
                                  menu.extras
                                      ?.map<Map<String, dynamic>>((e) => {
                                            'title': e.name,
                                            'subtitle': 'x${e.amount}',
                                            'trailing': e.costPrice * e.amount,
                                          })
                                      ?.toList(),
                                  'Extras'),
                              SingleElementExtraList(
                                  currencySnapshot.data,
                                  menu.meals
                                      ?.map<Map<String, dynamic>>((e) => {
                                            'title': e.name,
                                            'subtitle': 'x${e.amount}',
                                            'trailing': e.totalCost(_hourPrice) * e.amount,
                                          })
                                      ?.toList(),
                                  'Meals'),
                                  MyDeleteIconButton(
                                  myOnPressed: () => _deleteMealDialog(context),
                                ),
                            ],
                          );
                        });
                  });
            }),
      ),
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

    deleteSuccess = await _deleteMenuFromFile(menu);

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
      int deleteIndex = allMenus.indexWhere((element) => element.id == newMenu.id);
      allMenus.removeAt(deleteIndex);
      fileManagement.writeFile(menuJsonFile, jsonEncode(allMenus));
    } catch (error) {
      print('Error deleting menu: $error');
      return false;
    }
    return true;
  }
}
