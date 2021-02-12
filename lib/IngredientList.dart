import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/CreateIngredient.dart';
import 'package:profit_calculator/FileManagement.dart';

import 'Model/Ingredient.dart';

class IngredientList extends StatefulWidget {
  IngredientList({Key key}) : super(key: key);

  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  final FileManagement fileManagement = FileManagement();
  bool showArchived = false;
  String appBarTitle = 'All Ingredients';

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text('Name'),
                  trailing: Text('Kg/Liter Cost'),
                  dense: true,
                ),
              ),
              // Divider(
              //   thickness: 2,
              // ),
              FutureBuilder(
                future: fileManagement.readFile('IngredientListJson'),
                initialData: '',
                builder: (context, ingredientFileSnapshot) {
                  if (ingredientFileSnapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (ingredientFileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: Text("Loading"));
                  }
                  if (ingredientFileSnapshot.data.length == 0) {
                    return Center(
                        child: Text(
                      "You have no meals.\nCreate some in the menu.",
                      textAlign: TextAlign.center,
                    ));
                  }
//Map data from firestore to objects in list.
                  Iterable tempIngredientIterable =
                      json.decode(ingredientFileSnapshot.data);
                  List<Ingredient> ingredients = List<Ingredient>();
                  ingredients = tempIngredientIterable
                      ?.map((e) => Ingredient.fromJson(e))
                      ?.toList();
                  return new ListView.builder(
                    itemCount: ingredients.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ingredientListTile(ingredients[index]);
                    },
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  );
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
