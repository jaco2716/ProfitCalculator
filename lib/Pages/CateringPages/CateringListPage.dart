import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/InAppPurchase/components.dart';
import 'package:profit_calculator/InAppPurchase/upgrade.dart';
import 'package:profit_calculator/Model/Catering.dart';
import 'package:profit_calculator/Model/SortingElement.dart';
import 'package:profit_calculator/Model/SortingTypes.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/ElementListTile.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/MyTopListLabel.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/Pages/CateringPages/SingleCateringPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;
import 'CreateCateringPage.dart';

class CateringListPage extends StatefulWidget {
  CateringListPage({Key key}) : super(key: key);

  @override
  _CateringListPageState createState() => _CateringListPageState();
}

class _CateringListPageState extends State<CateringListPage> {
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  final FileManagement _fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  SortingElement sortingElement = SortingElement('   ', '▼', SortingTypes.trailingDescending);
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String menuJsonFile = config.menuJsonFile;
  final String extraJsonFile = config.extraJsonFile;
  final String cateringJsonFile = config.cateringJsonFile;
  List<Catering> caterings = [];

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
          tileTitle: 'Create Catering',
          myOnPressed: () {
            print(caterings.toString());
            if (!appData.isPro && caterings.length > 2) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UpgradeScreen(),
              ));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => CreateCateringPage(
                  editMode: false,
                ),
              ))
                  .then((value) {
                setState(() {});
              });
            }

            // setState(() {});
          }),
      appBar: MyAppBarWithCalc('All Caterings'),
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
                            future: _fileManagement.readFile(cateringJsonFile),
                            initialData: '',
                            builder: (BuildContext context, AsyncSnapshot cateringJsonSnapshot) {
                              if (cateringJsonSnapshot.connectionState == ConnectionState.waiting) {
                                return MyLoadingCircle(500);
                              }
                              if (cateringJsonSnapshot.data.length <= 2) {
                                return InitialFutureWidget();
                              }
                              caterings = objManager.jsonToListCatering(cateringJsonSnapshot.data);
                              switch (sortingElement.sortingType) {
                                case SortingTypes.leadingAscending:
                                  caterings.sort((a, b) => a.name.compareTo(b.name));
                                  break;
                                case SortingTypes.leadingDescending:
                                  caterings.sort((b, a) => a.name.compareTo(b.name));
                                  break;
                                case SortingTypes.trailingAscending:
                                  caterings
                                      .sort((a, b) => a.profitMargin(_hourPrice, _vatPercent).compareTo(b.profitMargin(_hourPrice, _vatPercent)));
                                  break;
                                case SortingTypes.trailingDescending:
                                  caterings
                                      .sort((b, a) => a.profitMargin(_hourPrice, _vatPercent).compareTo(b.profitMargin(_hourPrice, _vatPercent)));
                                  break;
                              }
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: ListView.builder(
                                      itemCount: caterings.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        Map<String, dynamic> element = {
                                          'title': caterings[index].name,
                                          'subtitle':
                                              '${caterings[index].ingredients.length} Ingredients\n${caterings[index].meals.length} Meals\n${caterings[index].extras.length} Extras',
                                          'trailing1': caterings[index].salePrice,
                                          'trailing2': caterings[index].profitMargin(_hourPrice, _vatPercent).round(),
                                        };
                                        return ElementListTile(element: element, myOnPressed: () => goToElementPage(caterings[index]));
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

  void goToElementPage(Catering catering) {
    //Go to catering page when tapped.
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => SingleCateringPage(catering),
    ))
        .then((context) {
      setState(() {});
    });
  }
}
