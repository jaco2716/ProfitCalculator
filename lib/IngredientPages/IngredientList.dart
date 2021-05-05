import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/CalculatorPage.dart';
import 'package:profit_calculator/IngredientPages/CreateIngredient.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/InitialFutureWidget.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import '../Model/EnvironmentConfig.dart' as config;

import '../Model/Ingredient.dart';

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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => CreateIngredient(),
            ))
                .then((context) {
              setState(() {});
            });
          },
          icon: Icon(Icons.add),
          label: Text('Create Ingredient'),
          style: ElevatedButton.styleFrom(
            primary: Colors.green, // background
            onPrimary: Colors.white, // foreground
          ),
        ),
      ),
      appBar: AppBar(
          // backgroundColor: showArchived ? Colors.red : Colors.blue,
          title: Text(appBarTitle),
          actions: [
            // IconButton(
            //     icon: showArchived
            //         ? Icon(Icons.archive_outlined)
            //         : Icon(Icons.archive),
            //     onPressed: () {
            //       setState(() {
            //         showArchived = !showArchived;
            //         if (showArchived)
            //           appBarTitle = 'Archived Ingredients';
            //         else
            //           appBarTitle = 'All Ingredients';
            //       });
            //     }),
            IconButton(
                icon: Icon(CupertinoIcons.plus_slash_minus),
                onPressed: () {
                  // Scaffold.of(context).showBottomSheet((context) => CalculatorPage());
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: CalculatorPage(),
                    duration: Duration(hours: 24),
                    behavior: SnackBarBehavior.floating,
                  ));
                }),
          ]),
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
                    if (ingredientJsonSnapshot.hasError) {
                      return Container(
                          height: 400,
                          child: Center(
                              child: Text(
                            'Something went wrong.\nPlease try restarting your app.',
                            textAlign: TextAlign.center,
                          )));
                    }

                    if (ingredientJsonSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                          height: 400,
                          child: Center(child: CircularProgressIndicator()));
                    }
                    if (ingredientJsonSnapshot.data.length == 0 || ingredientJsonSnapshot.data == '[]') {
                      return InitialFutureWidget();
                    }
//Map data from firestore to objects in list.
                    List<Ingredient> ingredients = objManager
                        .jsonToListIngredient(ingredientJsonSnapshot.data);

                    return FutureBuilder(
                      future: _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK'),
                  initialData: '',
                      builder: (context, currencySnapshot) {
                        print(ingredients[0].toString());
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: ListView.builder(
                            itemCount: ingredients.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ingredientListTile(ingredients[index], currencySnapshot.data);
                            },
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                          ),
                        );
                      }
                    );
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
