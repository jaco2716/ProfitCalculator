import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Model/BackupFileJson.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/Pages/BackupAndRestore/SaveBackupPage.dart';
import '../../MyWidgets/MyAppBarWithCalc.dart';
import '../../Model/EnvironmentConfig.dart' as config;
import 'package:intl/intl.dart';

class BackupAndRestore extends StatelessWidget {
  final FileManagement fileManagement = FileManagement();
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String extraJsonFile = config.extraJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  final String menuJsonFile = config.menuJsonFile;
  final String cateringJsonFile = config.cateringJsonFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('Backup & Restore'),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Center(child: Icon(Icons.settings, size: 60, color: Colors.grey[400])),
              ),
              Text('Local Backup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Local Backups are lost if you uninstall the app.\n', style: TextStyle(fontSize: 12, color: Colors.grey)),
              MyIconButton(tileIcon: Icon(Icons.save), tileTitle: "Save Backup", myOnPressed: () => goToPage(SaveBackupPage(false), context)),
              MyIconButton(
                  tileIcon: Icon(Icons.download_rounded), tileTitle: "Restore Backup", myOnPressed: () => goToPage(SaveBackupPage(true), context)),
              Divider(height: 40),
              Text('Remote Backup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('Export backup to another device or online.\nRemember to backup any data before importing a file.\n',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              MyIconButton(tileIcon: Icon(Icons.share), tileTitle: "Export Backup file", myOnPressed: () => exportBackup()),
              MyIconButton(tileIcon: Icon(Icons.import_export), tileTitle: "Import Backup file", myOnPressed: () => importBackup(context)),
            ],
          ),
        ),
      ),
    );
  }

  void goToPage(Widget _navigationPage, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => _navigationPage));
  }

  void exportBackup() async {
    try {
      String ingredientFileContent = await fileManagement.readFile('$ingredientJsonFile');
      String extraFileContent = await fileManagement.readFile('$extraJsonFile');
      String mealFileContent = await fileManagement.readFile('$mealJsonFile');
      String menuFileContent = await fileManagement.readFile('$menuJsonFile');
      String cateringFileContent = await fileManagement.readFile('$cateringJsonFile');

      BackupFileJson backupFileJson = BackupFileJson(
        ingredientJson: ingredientFileContent,
        extraJson: extraFileContent,
        mealJson: mealFileContent,
        menuJson: menuFileContent,
        cateringJson: cateringFileContent,
      );
      DateTime timeNow = DateTime.now();
      DateFormat dateFormat = DateFormat("yyyyMMdd");
      String dateString = dateFormat.format(timeNow);

      fileManagement.exportData('ProfCalculatorBackup_$dateString', jsonEncode(backupFileJson));
      // print(jsonEncode(backupFileJson));
    } catch (e) {}
  }

  void importBackup(BuildContext context) async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      BackupFileJson backupFileJson;
      if (result != null) {
        File file = File(result.files.single.path);
        String fileJson = await file.readAsString();

        backupFileJson = BackupFileJson.fromJson(json.decode(fileJson));
        fileManagement.writeFile(ingredientJsonFile, backupFileJson.ingredientJson);
        fileManagement.writeFile(extraJsonFile, backupFileJson.extraJson);
        fileManagement.writeFile(mealJsonFile, backupFileJson.mealJson);
        fileManagement.writeFile(menuJsonFile, backupFileJson.menuJson);
        fileManagement.writeFile(cateringJsonFile, backupFileJson.cateringJson);

        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'File imported',
              content: 'O',
              cancelText: 'Okay',
              infoDialog: true,
              widgetContext: Icon(Icons.check_circle_rounded, color: Colors.green, size: 90),
            );
          },
        );
      } else {
        print('User canceled filepicker');
        return;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(title: 'Error', content: 'File could not be importet.', cancelText: 'Okay', infoDialog: true);
        },
      );
      print('error: $e');
    }
  }
}
