import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/InAppPurchase/components.dart';
import 'package:profit_calculator/InAppPurchase/upgrade.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/Model/SortingElement.dart';
import 'package:profit_calculator/Model/SortingTypes.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/ElementListTile.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/MyTopListLabel.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/Pages/MenuPages/CreateMenuPage.dart';
import 'package:profit_calculator/Pages/MenuPages/SingleMenuPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class MenuListPage extends StatefulWidget {
  MenuListPage({Key key}) : super(key: key);

  @override
  _MenuListPageState createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  final FileManagement _fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  SortingElement sortingElement = SortingElement('   ', '▼', SortingTypes.trailingDescending);
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String menuJsonFile = config.menuJsonFile;
  final String extraJsonFile = config.extraJsonFile;
  List<Menu> menus = [];

  int _vatPercent;
  int _hourPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: MyIconButton(
          compact: true,
          tileIcon: Icon(Icons.add),
          buttonColor: Colors.green,
          tileTitle: 'Create Menu',
          myOnPressed: () {
            if (!appData.isPro && menus.length > 6) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UpgradeScreen(),
              ));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => CreateMenuPage(
                  editMode: false,
                ),
              ))
                  .then((value) {
                setState(() {});
              });
            }
          }),
      appBar: MyAppBarWithCalc('All Menus'),
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
                            future: _fileManagement.readFile(menuJsonFile),
                            initialData: '',
                            builder: (BuildContext context, AsyncSnapshot menuJsonSnapshot) {
                              if (menuJsonSnapshot.connectionState == ConnectionState.waiting) {
                                return MyLoadingCircle(500);
                              }
                              if (menuJsonSnapshot.data.length <= 2) {
                                return InitialFutureWidget();
                              }
                              menus = objManager.jsonToListMenu(menuJsonSnapshot.data);

                              switch (sortingElement.sortingType) {
                                case SortingTypes.leadingAscending:
                                  menus.sort((a, b) => a.name.compareTo(b.name));
                                  break;
                                case SortingTypes.leadingDescending:
                                  menus.sort((b, a) => a.name.compareTo(b.name));
                                  break;
                                case SortingTypes.trailingAscending:
                                  menus.sort((a, b) => a.profitMargin(_hourPrice, _vatPercent).compareTo(b.profitMargin(_hourPrice, _vatPercent)));
                                  break;
                                case SortingTypes.trailingDescending:
                                  menus.sort((b, a) => a.profitMargin(_hourPrice, _vatPercent).compareTo(b.profitMargin(_hourPrice, _vatPercent)));
                                  break;
                              }
                              int listLenght = menus.length;
                              if (!appData.isPro && menus.length > 3) {
                                listLenght = 3;
                              }

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: ListView.builder(
                                      itemCount: listLenght,
                                      itemBuilder: (BuildContext context, int index) {
                                        Map<String, dynamic> element = {
                                          'title': menus[index].name,
                                          'subtitle':
                                              '${menus[index].ingredients.length} Ingredients\n${menus[index].meals.length} Meals\n${menus[index].extras.length} Extras',
                                          'trailing1': menus[index].salePrice,
                                          'trailing2': menus[index].profitMargin(_hourPrice, _vatPercent).round(),
                                        };
                                        return ElementListTile(element: element, myOnPressed: () => goToElementPage(menus[index]));
                                      },
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                    ),
                                  ),
                                  !appData.isPro && menus.length > 3
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Opacity(
                                              opacity: 0.5,
                                              child: ElementListTile(element: {
                                                'title': '________________',
                                                'subtitle': '________\n_____\n____\n___',
                                                'trailing1': 75.0,
                                                'trailing2': 100,
                                              }, myOnPressed: null),
                                            ),
                                            Align(
                                                alignment: Alignment.center,
                                                child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.orange,
                                                      elevation: 0,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .push(MaterialPageRoute(
                                                        builder: (context) => UpgradeScreen(),
                                                      ))
                                                          .then((context) {
                                                        setState(() {});
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
                                                      child: Text(
                                                        'Upgrade to Premium\nto see all of your items',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ))),
                                          ],
                                        )
                                      : Center(),
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

  void goToElementPage(Menu menu) {
    //Go to menu page when tapped.
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => SingleMenuPage(menu),
    ))
        .then((context) {
      setState(() {});
    });
  }
}
