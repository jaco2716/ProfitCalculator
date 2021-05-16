import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/CalculatorPage.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/InitialFutureWidget.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
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
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

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
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => CreateIngredient(),
          ))
              .then((context) {
            setState(() {});
          });
        },
      ),
      appBar: MyAppBarWithCalc('Ingredients'),
      body: Stack(children: [
        SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 700),
              child: Column(children: [
                // Divider(
                //   thickness: 2,
                // ),
                FutureBuilder(
                  future: fileManagement.readFile(ingredientJsonFile),
                  initialData: '',
                  builder: (context, ingredientJsonSnapshot) {
                    if (ingredientJsonSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return MyLoadingCircle(500);
                    }
                    if (ingredientJsonSnapshot.data.length == 0 ||
                        ingredientJsonSnapshot.data == '[]') {
                      return InitialFutureWidget();
                    }
//Map data from firestore to objects in list.
                    List<Ingredient> ingredients = objManager
                        .jsonToListIngredient(ingredientJsonSnapshot.data);

                    return FutureBuilder(
                        future: _sharedValueHandler.getStringSharedP(
                            'CurrencyChosen', 'DKK'),
                        initialData: '',
                        builder: (context, currencySnapshot) {
                          if (currencySnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return MyLoadingCircle(500);
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ListView.builder(
                              itemCount: ingredients.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ingredientListTile(
                                    ingredients[index], currencySnapshot.data);
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
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45.0),
              child: ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  'Name',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  'Kg/Liter Cost',
                  style: TextStyle(fontSize: 16),
                ),
                dense: true,
              ),
            ),
          ),
        ),
      ]),
    );
  }

//List tile widget of every ingredient
  Widget ingredientListTile(Ingredient ingredient, String currency) {
    // if (!showArchived) {
    //   if (ingredient.archived) return Center();
    // } else {
    //   if (!ingredient.archived) return Center();
    // }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(ingredient.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${ingredient.kgPrice.toStringAsFixed(2)} $currency/${ingredient.measureUnit}'),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.edit,
                color: Colors.grey,
              ),
            )
          ],
        ),
        onTap: () {
//when tapped go to edit page.
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) =>
                CreateIngredient(editMode: true, editIngredient: ingredient),
          ))
              .then((context) {
            setState(() {});
          });
        },
      ),
    );
  }
}
