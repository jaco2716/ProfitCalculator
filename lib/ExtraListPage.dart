import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/CreateExtraPage.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/InitialFutureWidget.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import '../Model/EnvironmentConfig.dart' as config;
import 'Model/Extra.dart';
import 'MyAppBarWithCalc.dart';

class ExtraListPage extends StatefulWidget {
  ExtraListPage({Key key}) : super(key: key);

  @override
  _ExtraListPageState createState() => _ExtraListPageState();
}

class _ExtraListPageState extends State<ExtraListPage> {
  String extraJsonFile = config.extraJsonFile;
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
              builder: (context) => CreateExtra(),
            ))
                .then((context) {
              setState(() {});
            });
          },
          icon: Icon(Icons.add),
          label: Text('Create Extra'),
          style: ElevatedButton.styleFrom(
            primary: Colors.green, // background
            onPrimary: Colors.white, // foreground
          ),
        ),
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
                    if (extraJsonSnapshot.hasError) {
                      return Container(
                          height: 400,
                          child: Center(
                              child: Text(
                            'Something went wrong.\nPlease try restarting your app.',
                            textAlign: TextAlign.center,
                          )));
                    }

                    if (extraJsonSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                          height: 400,
                          child: Center(child: CircularProgressIndicator()));
                    }
                    if (extraJsonSnapshot.data.length == 0 || extraJsonSnapshot.data == '[]') {
                      return InitialFutureWidget();
                    }
                    List<Extra> extras = objManager
                        .jsonToListExtra(extraJsonSnapshot.data);

                    return FutureBuilder(
                        future: _sharedValueHandler.getStringSharedP(
                            'CurrencyChosen', 'DKK'),
                        initialData: '',
                        builder: (context, currencySnapshot) {
                          // print(extras[0].toString());
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ListView.builder(
                              itemCount: extras.length,
                              itemBuilder: (BuildContext context, int index) {
                                return extraListTile(
                                    extras[index], currencySnapshot.data);
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

//List tile widget of every extra
  Widget extraListTile(Extra extra, String currency) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(extra.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${extra.buyPrice.toString()} / ${extra.salePrice.toString()},- $currency'),
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
                CreateExtra(editMode: true, editExtra: extra),
          ))
              .then((context) {
            setState(() {});
          });
        },
      ),
    );
  }
}
