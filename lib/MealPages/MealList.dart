import 'package:flutter/material.dart';
import 'package:profit_calculator/MealPages/CreateMeal.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/InitialFutureWidget.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MealPages/SingleMeal.dart';
import '../Model/EnvironmentConfig.dart' as config;

import '../Model/Ingredient.dart';
import '../Model/Meal.dart';

class MealList extends StatefulWidget {
  final bool isMealList;
  MealList(this.isMealList);

  @override
  _MealListState createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  bool isLoading = false;

  final String ingredientJsonFile = config.ingredientJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  final String menuJsonFile = config.menuJsonFile;
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  // int calculatorPadding = 10;

  @override
  Widget build(BuildContext context) {
//Show a loading circle if isLoading is true.
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            if (widget.isMealList) {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => CreateMeal(
                  isMeals: true,
                ),
              ))
                  .then((value) {
                setState(() {});
              });
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => CreateMeal(
                  isMeals: false,
                ),
              ))
                  .then((value) {
                setState(() {});
              });
            }
            // setState(() {});
          },
          icon: Icon(Icons.add),
          label: Text(widget.isMealList ? 'Create Meal' : 'Create Menu'),
          style: ElevatedButton.styleFrom(
            primary: Colors.green, // background
            onPrimary: Colors.white, // foreground
          ),
        ),
      ),
      appBar: MyAppBarWithCalc(widget.isMealList ? 'All Meals' : 'All Menus'),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 700),
                    child: FutureBuilder(
                      future: fileManagement.readFile(mealJsonFile),
                      initialData: '',
                      builder: (context, mealJsonSnapshot) {
                        // print(mealFileSnapshot.data);
                        if (mealJsonSnapshot.hasError) {
                          return Container(
                              height: 400,
                              child: Center(
                                  child: Text(
                                'Something went wrong.\nPlease try restarting your app.',
                                textAlign: TextAlign.center,
                              )));
                        }

                        if (mealJsonSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                              height: 400,
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }
                        if (mealJsonSnapshot.data.length == 0 &&
                            widget.isMealList) {
                          return InitialFutureWidget();
                        }
                        //Map data from firestore to list of objects
                        List<Meal> meals =
                            objManager.jsonToListMeal(mealJsonSnapshot.data);

                            // meals.sort((a,b) => a.profitMargin.compareTo(b.profitMargin));

                        return FutureBuilder(
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
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              }
                              //Make ingredients from firestore to new list.
                              List<Ingredient> allIngredients =
                                  objManager.jsonToListIngredient(
                                      ingredientJsonSnapshot.data);
                              //JOIN meals with updated ingredients.
                              meals.forEach((meal) {
                                meal.ingredients.forEach((mIngredient) {
                                  allIngredients.forEach((aIngredient) {
                                    if (mIngredient.id == aIngredient.id) {
                                      mIngredient.name = aIngredient.name;
                                      mIngredient.color = aIngredient.color;
                                      mIngredient.kgPrice = aIngredient.kgPrice;
                                      mIngredient.measureUnit =
                                          aIngredient.measureUnit;
                                    }
                                  });
                                });
                              });

                              if (widget.isMealList) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: ListView.builder(
                                        itemCount: meals.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return mealListTile(meals[index]);
                                        },
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                      ),
                                    ),
                                    SizedBox(height: 400),
                                  ],
                                );
                              } else {
                                return FutureBuilder(
                                  future: fileManagement.readFile(menuJsonFile),
                                  initialData: '',
                                  builder: (BuildContext context,
                                      AsyncSnapshot menuJsonSnapshot) {
                                    if (menuJsonSnapshot.hasError) {
                                      return Container(
                                          height: 400,
                                          child: Center(
                                              child: Text(
                                            'Something went wrong.\nPlease try restarting your app.',
                                            textAlign: TextAlign.center,
                                          )));
                                    }
                                    if (menuJsonSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                          height: 400,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()));
                                    }
                                    if (menuJsonSnapshot.data.length == 0) {
                                      return InitialFutureWidget();
                                    }
                                    List<Menu> menus = objManager
                                        .jsonToListMenu(menuJsonSnapshot.data);
                                    //JOIN menus with updated ingredients.
                                    menus.forEach((menu) {
                                      menu.ingredients.forEach((mIngredient) {
                                        allIngredients.forEach((aIngredient) {
                                          if (mIngredient.id ==
                                              aIngredient.id) {
                                            mIngredient.name = aIngredient.name;
                                            mIngredient.color =
                                                aIngredient.color;
                                            mIngredient.kgPrice =
                                                aIngredient.kgPrice;
                                            mIngredient.measureUnit =
                                                aIngredient.measureUnit;
                                          }
                                        });
                                      });
                                      menu.meals.forEach((mMeal) {
                                        meals.forEach((aMeal) {
                                          if (mMeal.id == aMeal.id) {
                                            mMeal.name = aMeal.name;
                                            mMeal.salePrice = aMeal.salePrice;
                                          }
                                        });
                                      });
                                    });

                                    return Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 40),
                                          child: ListView.builder(
                                            itemCount: menus.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return menuListTile(menus[index]);
                                            },
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                          ),
                                        ),
                                        SizedBox(height: 400),
                                      ],
                                    );
                                  },
                                );
                              }
                            });
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'Name',
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: Text(
                        'Price/Profit',
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

//List Tile for every meal
  Widget mealListTile(Meal meal) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(meal.name),
        subtitle: Text('${meal.ingredients.length} Ingredients'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${meal.salePrice.toStringAsFixed(2)},-',
              style: TextStyle(color: Colors.blue),
            ),
            Text(' / '),
            Text(
              '${meal.profit.toStringAsFixed(2)},-',
              style: TextStyle(
                  color: meal.profit > 0 ? Colors.green : Colors.orange[700]),
            ),
          ],
        ),
        onTap: () {
//Go to meal page when tapped.
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => SingleMeal(meal: meal, isMeal: true),
          ))
              .then((context) {
            setState(() {});
          });
          print(meal.name + ' Tapped!');
        },
      ),
    );
  }

  Widget menuListTile(Menu menu) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(menu.name),
        subtitle: Text(
            '${menu.ingredients.length} Ingredients\n${menu.meals.length} Meals'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${menu.salePrice.toStringAsFixed(2)},-',
              style: TextStyle(color: Colors.blue),
            ),
            Text(' / '),
            Text(
              '${menu.profit.toStringAsFixed(2)},-',
              style: TextStyle(
                  color: menu.profit > 0 ? Colors.green : Colors.orange[700]),
            ),
          ],
        ),
        onTap: () {
//Go to menu page when tapped.
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => SingleMeal(menu: menu, isMeal: false),
          ))
              .then((context) {
            setState(() {});
          });

          print(menu.name + ' Tapped!');
        },
      ),
    );
  }
}
