import 'package:flutter/material.dart';
import 'package:profit_calculator/BackupAndRestore/SaveBackupPage.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/MyWidgets/WideMenuIconButton.dart';
import '../Model/EnvironmentConfig.dart' as config;

class BackupAndRestore extends StatelessWidget {
  final FileManagement fileManagement = FileManagement();
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup & Restore'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
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
            // Container(
            //   padding: EdgeInsets.all(30),
            //   child: Center(child: Text('Welcome', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200,)))),
            // drawerListTile(
              // tileIcon: Icon(Icons.save),
              // tileTitle: "Save Backup",
              // myOnPressed: () {
              //   goToPage(SaveBackupPage(false), context);
              // },
            // ),
            WideMenuIconButton(
              tileIcon: Icon(Icons.save),
              tileTitle: "Save Backup",
              myOnPressed: () {
                goToPage(SaveBackupPage(false), context);
              },
            ),
            WideMenuIconButton(
              tileIcon: Icon(Icons.download_rounded),
              tileTitle: "Restore Backup",
              myOnPressed: () {
                goToPage(SaveBackupPage(true), context);
              },
            ),
            // drawerListTile(
            //   tileIcon: Icon(Icons.download_rounded),
            //   tileTitle: "Restore Backup",
            //   myOnPressed: () {
            //     goToPage(SaveBackupPage(true), context);
            //   },
            // ),
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
