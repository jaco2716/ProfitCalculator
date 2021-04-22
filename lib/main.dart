import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/CalculatorPage.dart';
import 'package:profit_calculator/FileManagement.dart';
import 'package:profit_calculator/FrontPageMenu.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import 'Model/EnvironmentConfig.dart' as config;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    config.saveFileChosen = 4;
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // brightness: Brightness.light,
          appBarTheme: AppBarTheme(brightness: Brightness.dark),
          primarySwatch: Colors.blue,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          )),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FileManagement fileManagement = FileManagement();
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBarWithCalc('Profit Calculator'),
        // appBar: AppBar(//MyAppBarWithCalc('Profit Calculator'),
        // title: Text('Profit Calculator'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.save),
        //     onPressed: () {
        //       fileManagement.exportData(
        //           context, ingredientJsonFile, mealJsonFile);
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.download_rounded),
        //     onPressed: () async {
        //       await fileManagement.importData();
        //       setState(() {

        //       });
        //       // FilePickerResult result =
        //       //     await FilePicker.platform.pickFiles();
        //     },
        //   )
        // ],
        // ),
        // drawer: MyDrawer(),
        // body: MealList());
        body: FrontPageMenu());
  }
}
