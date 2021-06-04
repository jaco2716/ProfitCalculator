import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/InAppPurchase/components.dart';
import 'package:profit_calculator/InAppPurchase/upgrade.dart';
import 'package:profit_calculator/Model/SortingElement.dart';
import 'package:profit_calculator/Model/SortingTypes.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/ElementListTile.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/MyTopListLabel.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/Pages/ExtraPages/CreateExtraPage.dart';
import 'package:profit_calculator/Pages/ExtraPages/SingleExtraPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;
import '../../Model/Extra.dart';
import '../../MyWidgets/MyAppBarWithCalc.dart';

class ExtraListPage extends StatefulWidget {
  ExtraListPage({Key key}) : super(key: key);

  @override
  _ExtraListPageState createState() => _ExtraListPageState();
}

class _ExtraListPageState extends State<ExtraListPage> {
  String extraJsonFile = config.extraJsonFile;
  int _vatPercent;
  SortingElement sortingElement = SortingElement('   ', '▼', SortingTypes.trailingDescending);
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  List<Extra> extras;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: MyIconButton(
        tileIcon: Icon(Icons.add),
        tileTitle: 'Create Extra',
        compact: true,
        buttonColor: Colors.green,
        myOnPressed: () {
          if (!appData.isPro && extras.length > 1) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UpgradeScreen(),
            ));
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => CreateExtra(),
            ))
                .then((context) {
              setState(() {});
            });
          }
        },
      ),
      appBar: MyAppBarWithCalc('Extras'),
      body: Stack(children: [
        SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 700),
              child: Column(children: [
                FutureBuilder(
                  future: fileManagement.readFile(extraJsonFile),
                  initialData: '',
                  builder: (context, extraJsonSnapshot) {
                    if (extraJsonSnapshot.connectionState == ConnectionState.waiting) {
                      return MyLoadingCircle(500);
                    }
                    if (extraJsonSnapshot.data.length == 0 || extraJsonSnapshot.data == '[]') {
                      return InitialFutureWidget();
                    }
                    extras = objManager.jsonToListExtra(extraJsonSnapshot.data);

                    return FutureBuilder(
                        future: _sharedValueHandler.getIntSharedP('VATPercent', 25),
                        initialData: '',
                        builder: (context, vatSnapshot) {
                          if (vatSnapshot.connectionState == ConnectionState.waiting) {
                            return MyLoadingCircle(500);
                          }
                          _vatPercent = vatSnapshot.data;
                          switch (sortingElement.sortingType) {
                            case SortingTypes.leadingAscending:
                              extras.sort((a, b) => a.name.compareTo(b.name));
                              break;
                            case SortingTypes.leadingDescending:
                              extras.sort((b, a) => a.name.compareTo(b.name));
                              break;
                            case SortingTypes.trailingAscending:
                              extras.sort((a, b) => a.profitMargin(_vatPercent).compareTo(b.profitMargin(_vatPercent)));
                              break;
                            case SortingTypes.trailingDescending:
                              extras.sort((b, a) => a.profitMargin(_vatPercent).compareTo(b.profitMargin(_vatPercent)));
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
                                    itemCount: extras.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      Map<String, dynamic> element = {
                                        'title': extras[index].name,
                                        'subtitle': null,
                                        'trailing1': extras[index].salePrice,
                                        'trailing2': extras[index].profitMargin(_vatPercent).round(),
                                      };
                                      return ElementListTile(element: element, myOnPressed: () => _goToExtraPage(extras[index]));
                                    },
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                  ),
                                );
                              });
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

  void _goToExtraPage(Extra extra) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => SingleExtraPage(extra),
    ))
        .then((context) {
      setState(() {});
    });
  }
}
