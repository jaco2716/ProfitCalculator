import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/ElementListTile.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/MyTopListLabel.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import '../../Model/EnvironmentConfig.dart' as config;
import 'CreateMeal.dart';
import 'SingleMeal.dart';

class MealListPage extends StatefulWidget {
  @override
  _MealListPageState createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  int _hourPrice = 0;
  int _vatPercent = 0;
  final String mealJsonFile = config.mealJsonFile;
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: MyIconButton(
          compact: true,
          tileIcon: Icon(Icons.add),
          buttonColor: Colors.green,
          tileTitle: 'Create Meal',
          myOnPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => CreateMeal(
                isMeals: true,
              ),
            ))
                .then((value) {
              setState(() {});
            });
          }),
      appBar: MyAppBarWithCalc('All Meals'),
      body: Stack(children: [
        SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 700),
              child: FutureBuilder(
                  future: _sharedValueHandler.getIntSharedP('VATPercent', 25),
                  builder: (context, vatSnapshot) {
                    if (vatSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return MyLoadingCircle(500);
                    }
                    _vatPercent = vatSnapshot.data;
                    return FutureBuilder(
                        future:
                            _sharedValueHandler.getIntSharedP('hourPrice', 100),
                        builder: (context, hourSnapshot) {
                          if (hourSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return MyLoadingCircle(500);
                          }
                          _hourPrice = hourSnapshot.data;
                          return FutureBuilder(
                            future: fileManagement.readFile(mealJsonFile),
                            initialData: '',
                            builder: (context, mealJsonSnapshot) {
                              if (mealJsonSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return MyLoadingCircle(500);
                              }
                              if (mealJsonSnapshot.data.length <= 2) {
                                return InitialFutureWidget();
                              }
                              //Map data from file to list of objects
                              List<Meal> meals = objManager
                                  .jsonToListMeal(mealJsonSnapshot.data);

                              meals.sort((b, a) => a
                                  .profitMargin(_hourPrice, _vatPercent)
                                  .compareTo(
                                      b.profitMargin(_hourPrice, _vatPercent)));

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: ListView.builder(
                                      itemCount: meals.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        Map<String, dynamic> element = {
                                          'title': meals[index].name,
                                          'subtitle':
                                              '${meals[index].ingredients.length} Ingredients',
                                          'trailing1': meals[index].salePrice,
                                          'trailing2': meals[index]
                                              .profitMargin(
                                                  _hourPrice, _vatPercent)
                                              .round(),
                                        };
                                        return ElementListTile(
                                            element: element,
                                            myOnPressed: () =>
                                                goToElementPage(meals[index]));
                                      },
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                    ),
                                  ),
                                  SizedBox(height: 400),
                                ],
                              );
                            },
                          );
                        });
                  }),
            ),
          ),
        ),
        MyTopListLabel(title: 'Name', trailing: 'Price / Profit %'),
      ]),
    );
  }

  void goToElementPage(Meal meal) {
    //Go to menu page when tapped.
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => SingleMeal(meal: meal, isMeal: false),
    ))
        .then((context) {
      setState(() {});
    });
  }
}
