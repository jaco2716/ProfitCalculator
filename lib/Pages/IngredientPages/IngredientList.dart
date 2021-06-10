import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Model/SortingElement.dart';
import 'package:profit_calculator/Model/SortingTypes.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/MyTopListLabel.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/SmallElementListTile.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import '../../Model/EnvironmentConfig.dart' as config;
import '../../Model/Ingredient.dart';
import 'CreateIngredient.dart';

class IngredientList extends StatefulWidget {
  IngredientList({Key key}) : super(key: key);

  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  // bool showArchived = false;
  String appBarTitle = 'All Ingredients';
  String ingredientJsonFile = config.ingredientJsonFile;
  SortingElement sortingElement = SortingElement('   ', '▼', SortingTypes.trailingDescending);

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  List<Ingredient> ingredients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: MyIconButton(
        tileIcon: Icon(Icons.add),
        tileTitle: 'Create Ingredient',
        compact: true,
        buttonColor: Colors.green,
        myOnPressed: () {
          // if (!appData.isPro && ingredients.length > 9) {
          //   Navigator.of(context).push(MaterialPageRoute(
          //     builder: (context) => UpgradeScreen(),
          //   ));
          // } else {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => CreateIngredient(),
            ))
                .then((context) {
              setState(() {});
            });
          // }
        },
      ),
      appBar: MyAppBarWithCalc('Ingredients'),
      body: Stack(children: [
        SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 700),
              child: Column(children: [
                FutureBuilder(
                  future: fileManagement.readFile(ingredientJsonFile),
                  initialData: '',
                  builder: (context, ingredientJsonSnapshot) {
                    if (ingredientJsonSnapshot.connectionState == ConnectionState.waiting) {
                      return MyLoadingCircle(500);
                    }
                    if (ingredientJsonSnapshot.data.length == 0 || ingredientJsonSnapshot.data == '[]') {
                      return InitialFutureWidget();
                    }
//Map data from file to objects in list.
                    ingredients = objManager.jsonToListIngredient(ingredientJsonSnapshot.data);

                    switch (sortingElement.sortingType) {
                      case SortingTypes.leadingAscending:
                        ingredients.sort((a, b) => a.name.compareTo(b.name));
                        break;
                      case SortingTypes.leadingDescending:
                        ingredients.sort((b, a) => a.name.compareTo(b.name));
                        break;
                      case SortingTypes.trailingAscending:
                        ingredients.sort((a, b) => a.kgPrice.compareTo(b.kgPrice));
                        break;
                      case SortingTypes.trailingDescending:
                        ingredients.sort((b, a) => a.kgPrice.compareTo(b.kgPrice));
                        break;
                    }

                    return FutureBuilder(
                        future: _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK'),
                        initialData: '',
                        builder: (context, currencySnapshot) {
                          if (currencySnapshot.connectionState == ConnectionState.waiting) {
                            return MyLoadingCircle(500);
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ListView.builder(
                              itemCount: ingredients.length,
                              itemBuilder: (BuildContext context, int index) {
                                //${currencySnapshot.data}
                                Map<String, dynamic> element = {
                                  'title': ingredients[index].name,
                                  'trailing': '${ingredients[index].kgPrice.toStringAsFixed(2)},- /${ingredients[index].measureUnit}'
                                };
                                return SmallElementListTile(element: element, myOnPressed: () => _goToIngredientPage(ingredients[index]));
                              },
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                            ),
                          );
                        });
                  },
                ),
                SizedBox(height: 400),
              ]),
            ),
          ),
        ),
        MyTopListLabel(
          title: 'Name ${sortingElement.leadingText}',
          trailing: 'Kg/Liter Cost ${sortingElement.trailingText}',
          sortByLeading: () {
            setState(() {
              sortingElement.sortByLeading();
            });
          },
          sortByTrailing: () {
            setState(() {
              sortingElement.sortByTrailing();
            });
          },
        ),
      ]),
    );
  }

  void _goToIngredientPage(Ingredient ingredient) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => CreateIngredient(editMode: true, editIngredient: ingredient),
    ))
        .then((context) {
      setState(() {});
    });
  }
}
