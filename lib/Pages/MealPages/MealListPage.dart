import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/InAppPurchase/components.dart';
import 'package:profit_calculator/InAppPurchase/upgrade.dart';
import 'package:profit_calculator/Model/SortingElement.dart';
import 'package:profit_calculator/Model/SortingTypes.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/ElementListTile.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/MyTopListLabel.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/upgradeToSeeItems.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/Pages/MealPages/CreateMealPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;
import 'SingleMealPage.dart';

class MealListPage extends StatefulWidget {
  @override
  _MealListPageState createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  int _hourPrice = 0;
  int _vatPercent = 0;
  SortingElement sortingElement = SortingElement('   ', '▼', SortingTypes.trailingDescending);

  final int maxFreeItems = 3;
  final String mealJsonFile = config.mealJsonFile;
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  List<Meal> meals = [];

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
            if (!appData.isPro && meals.length >= maxFreeItems) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UpgradeScreen(),
              ));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => CreateMealPage(),
              ))
                  .then((value) {
                setState(() {});
              });
            }
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
                    if (vatSnapshot.connectionState == ConnectionState.waiting) {
                      return MyLoadingCircle(500);
                    }
                    _vatPercent = vatSnapshot.data;
                    return FutureBuilder(
                        future: _sharedValueHandler.getIntSharedP('hourPrice', 100),
                        builder: (context, hourSnapshot) {
                          if (hourSnapshot.connectionState == ConnectionState.waiting) {
                            return MyLoadingCircle(500);
                          }
                          _hourPrice = hourSnapshot.data;
                          return FutureBuilder(
                            future: fileManagement.readFile(mealJsonFile),
                            initialData: '',
                            builder: (context, mealJsonSnapshot) {
                              if (mealJsonSnapshot.connectionState == ConnectionState.waiting) {
                                return MyLoadingCircle(500);
                              }
                              if (mealJsonSnapshot.data.length <= 2) {
                                return InitialFutureWidget();
                              }
                              //print(mealJsonSnapshot.data);
                              //Map data from file to list of objects
                              meals = objManager.jsonToListMeal(mealJsonSnapshot.data);
                              switch (sortingElement.sortingType) {
                                case SortingTypes.leadingAscending:
                                  meals.sort((a, b) => a.name.compareTo(b.name));
                                  break;
                                case SortingTypes.leadingDescending:
                                  meals.sort((b, a) => a.name.compareTo(b.name));
                                  break;
                                case SortingTypes.trailingAscending:
                                  meals.sort((a, b) => a.profitMargin(_hourPrice, _vatPercent).compareTo(b.profitMargin(_hourPrice, _vatPercent)));
                                  break;
                                case SortingTypes.trailingDescending:
                                  meals.sort((b, a) => a.profitMargin(_hourPrice, _vatPercent).compareTo(b.profitMargin(_hourPrice, _vatPercent)));
                                  break;
                              }

                              int listLenght = meals.length;
                              if (!appData.isPro && meals.length > maxFreeItems) {
                                listLenght = maxFreeItems;
                              }

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: ListView.builder(
                                      itemCount: listLenght,
                                      itemBuilder: (BuildContext context, int index) {
                                        Map<String, dynamic> element = {
                                          'title': meals[index].name,
                                          'subtitle': '${meals[index].ingredients.length} Ingredients',
                                          'trailing1': meals[index].salePrice,
                                          'trailing2': meals[index].profitMargin(_hourPrice, _vatPercent).round(),
                                        };
                                        return ElementListTile(element: element, myOnPressed: () => goToElementPage(meals[index]));
                                      },
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                    ),
                                  ),
                                  !appData.isPro && meals.length > maxFreeItems ? UpgradeToSeeItems(thisState: setState) : Center(),
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
        MyTopListLabel(
          title: 'Name ${sortingElement.leadingText}',
          trailing: 'Price / Profit % ${sortingElement.trailingText}',
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

  void goToElementPage(Meal meal) {
    //Go to menu page when tapped.
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => SingleMealPage(meal),
    ))
        .then((context) {
      setState(() {});
    });
  }
}
