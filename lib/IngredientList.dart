import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/CreateIngredient.dart';
import 'package:profit_calculator/FileManagement.dart';
import 'package:profit_calculator/InitialFutureWidget.dart';
import 'package:profit_calculator/ObjectManager.dart';
import 'Model/EnvironmentConfig.dart' as config;

import 'Model/Ingredient.dart';

class IngredientList extends StatefulWidget {
  IngredientList({Key key}) : super(key: key);

  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  bool showArchived = false;
  String appBarTitle = 'All Ingredients';
  String ingredientJsonFile = config.ingredientJsonFile;
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle), actions: [
        IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
              setState(() {
                showArchived = !showArchived;
                if (showArchived)
                  appBarTitle = 'Archived Ingredients';
                else
                  appBarTitle = 'All Ingredients';
              });
            }),
      ]),
      body: SingleChildScrollView(
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
                  if (ingredientJsonSnapshot.data.length == 0) {
                    return InitialFutureWidget();
                  }
//Map data from firestore to objects in list.
                  List<Ingredient> ingredients = objManager
                      .jsonToListIngredient(ingredientJsonSnapshot.data);

                  return Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45.0),
                      child: ListTile(
                        visualDensity: VisualDensity.compact,
                        title: Text('Name'),
                        trailing: Text('Kg/Liter Cost'),
                        dense: true,
                      ),
                    ),
                    ListView.builder(
                      itemCount: ingredients.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ingredientListTile(ingredients[index]);
                      },
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ]);
                },
              ),
              SizedBox(
                height: 50,
              )
            ]),
          ),
        ),
      ),
    );
  }

//List tile widget of every ingredient
  Widget ingredientListTile(Ingredient ingredient) {
    if (!showArchived) {
      if (ingredient.archived) return Center();
    } else {
      if (!ingredient.archived) return Center();
    }
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Color(ingredient.color),
            radius: 10,
          ),
          Text('   ' + ingredient.name),
        ]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${ingredient.kgPrice.toString()} Kr/${ingredient.measureUnit}'),
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
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                CreateIngredient(editMode: true, editIngredient: ingredient),
          ));
        },
      ),
    );
  }
}
