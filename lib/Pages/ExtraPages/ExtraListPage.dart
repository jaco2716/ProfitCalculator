import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/SmallElementListTile.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/Pages/ExtraPages/CreateExtraPage.dart';
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
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

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
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => CreateExtra(),
          ))
              .then((context) {
            setState(() {});
          });
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
                    if (extraJsonSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return MyLoadingCircle(500);
                    }
                    if (extraJsonSnapshot.data.length == 0 ||
                        extraJsonSnapshot.data == '[]') {
                      return InitialFutureWidget();
                    }
                    List<Extra> extras =
                        objManager.jsonToListExtra(extraJsonSnapshot.data);

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
                              itemCount: extras.length,
                              itemBuilder: (BuildContext context, int index) {
                                Map<String, dynamic> element = {
                                  'title': extras[index].name,
                                  'trailing':
                                      '${extras[index].costPrice.toStringAsFixed(2)},- / ${extras[index].salePrice.toStringAsFixed(2)},-'
                                };

                                return SmallElementListTile(
                                    element: element,
                                    myOnPressed: () =>
                                        _goToExtraPage(extras[index]));
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
                  'Buy / Saleprice',
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

  void _goToExtraPage(Extra extra) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => CreateExtra(editMode: true, editExtra: extra),
    ))
        .then((context) {
      setState(() {});
    });
  }
}
