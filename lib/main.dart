import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/PurchaseHandler.dart';
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
  final PurchaseHandler _purchaseHandler = PurchaseHandler();
  // reset() async {
  //   await _sharedValueHandler.saveIntSharedP(0, 'newUser');
  // }

  @override
  void initState() {
    super.initState();
    _purchaseHandler.initPurchaseState();
  }

  @override
  Widget build(BuildContext context) {
    // reset();

    return MaterialApp(
      title: 'Profit Calculator',
      theme: ThemeData(
          appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
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
