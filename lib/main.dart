import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Pages/FrontPageMenu.dart';

import 'Handlers/SharedValueHandler.dart';
import 'InAppPurchase/components.dart';
import 'MyWidgets/FrontPageWidgets/MyFirstTimeLoadingWidget.dart';
import 'MyWidgets/MyLoadingCircle.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  reset() async {
    await _sharedValueHandler.saveIntSharedP(0, 'newUser');
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    appData.isPro = false;

    // await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("tsZsqXbTbbzAZavjqlWhKLUwPtCkkJtP");

    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo.toString());
      if (purchaserInfo.entitlements.all['all_features'] != null) {
        appData.isPro = purchaserInfo.entitlements.all['all_features'].isActive;
      } else {
        appData.isPro = false;
      }
    } on PlatformException catch (e) {
      print(e);
    }

    print('#### is user pro? ${appData.isPro}');
  }

  @override
  Widget build(BuildContext context) {
    // reset();

    return MaterialApp(
      title: 'Profit Calculator',
      theme: ThemeData(
          // brightness: Brightness.light,
          appBarTheme: AppBarTheme(brightness: Brightness.dark),
          primarySwatch: Colors.blue,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          )),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
          future: _sharedValueHandler.getIntSharedP('newUser', 0),
          builder: (context, newUserSnapshot) {
            if (newUserSnapshot.connectionState == ConnectionState.waiting) {
              return MyLoadingCircle(500);
            }
            if (newUserSnapshot.data == 0) {
              return MyFirstTimeLoadingWidget();
            }
            return FrontPageMenu();
          }),
    );
  }
}
