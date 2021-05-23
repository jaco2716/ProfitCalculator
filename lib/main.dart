import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Pages/FrontPageMenu.dart';

import 'Handlers/SharedValueHandler.dart';
import 'MyWidgets/FrontPageWidgets/MyFirstTimeLoadingWidget.dart';
import 'MyWidgets/MyLoadingCircle.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  // This widget is the root of your application.
  reset() async {
    await _sharedValueHandler.saveIntSharedP(0, 'newUser');
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
      // home: MyHomePage(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   // final FileManagement fileManagement = FileManagement();
//   // final String ingredientJsonFile = config.ingredientJsonFile;
//   // final String mealJsonFile = config.mealJsonFile;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // appBar: MyAppBarWithCalc('Menu'),
//         body: FrontPageMenu());
//   }
// }
