import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/Pages/BackupAndRestore/SaveBackupPage.dart';
import '../../MyWidgets/MyAppBarWithCalc.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class BackupAndRestore extends StatelessWidget {
  final FileManagement fileManagement = FileManagement();
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: MyAppBarWithCalc('Backup & Restore'),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Icon(
                  Icons.settings,
                  size: 80,
                  color: Colors.blue[200],
                ),
              ),
            ),
            MyIconButton(
              tileIcon: Icon(Icons.save),
              tileTitle: "Save Backup",
              myOnPressed: () {
                goToPage(SaveBackupPage(false), context);
              },
            ),
            MyIconButton(
              tileIcon: Icon(Icons.download_rounded),
              tileTitle: "Restore Backup",
              myOnPressed: () {
                goToPage(SaveBackupPage(true), context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void goToPage(Widget _navigationPage, BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => _navigationPage));
  }
}
