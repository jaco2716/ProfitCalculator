import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import '../Model/EnvironmentConfig.dart' as config;

class SaveBackupPage extends StatelessWidget {
  final FileManagement fileManagement = FileManagement();
  final String mealJsonFile = config.mealJsonFile;
  final String ingredientJsonFile = config.ingredientJsonFile;
  bool restorePageSelected;

  List<String> saveButtonDates = [];
  String saveButtonTitle;
  String pageTitle;

  SharedValueHandler _sharedValueHandler = SharedValueHandler();

  SaveBackupPage(this.restorePageSelected);

  @override
  Widget build(BuildContext context) {
    if (restorePageSelected) {
      saveButtonTitle = 'Restore from slot ';
      pageTitle = 'Restore your data from a previous save file.';
    } else {
      saveButtonTitle = 'Save to slot ';
      pageTitle = 'Save your data to a save file, and be able to restore it at a later time.';
    }
    
      
    return Scaffold(
      appBar: MyAppBarWithCalc(
          restorePageSelected ? 'Restore Backup' : 'Save Backup'),
      body: Container(
        width: double.infinity,
        // color: Colors.amber,
        padding: EdgeInsets.all(20),
        child: FutureBuilder(
          future: _sharedValueHandler.getStringSharedP('saveAndRestoreDates', 'default'),
          builder: (context, snapshot) {
            return Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    pageTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                saveSlotButton(saveButtonTitle, '01/10/2021', 1),
                saveSlotButton(saveButtonTitle, '01/27/2021', 2),
                saveSlotButton(saveButtonTitle, '02/03/2021', 3),
                saveSlotButton(saveButtonTitle, '02/17/2021', 4),
                saveSlotButton(saveButtonTitle, '02/27/2021', 5),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget saveSlotButton(String title, String dateLastSaved, int index) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 250,
      height: 80,
      // padding: EdgeInsets.all(20),
      // margin: EdgeInsets.all(20),
      child: ElevatedButton.icon(
        style: ButtonStyle(),
        icon: Icon(Icons.save),
        label: Text('$title$index \nLast save: $dateLastSaved'),
        onPressed: () async {
          if (restorePageSelected) {
            String ingredientFileContent =
                await fileManagement.readFile(ingredientJsonFile);
            fileManagement.writeFile(
                '$ingredientJsonFile$index', ingredientFileContent);
            String mealFileContent =
                await fileManagement.readFile(mealJsonFile);
            fileManagement.writeFile('$mealJsonFile$index', mealFileContent);
          } else {}
        },
      ),
    );
  }

  void saveDataToSaveFile() {}

  void restoreDataFromSaveFile(int index) async {
    String ingredientFileContent =
        await fileManagement.readFile('$ingredientJsonFile$index');
    String mealFileContent =
        await fileManagement.readFile('$mealJsonFile$index');

    fileManagement.writeFile(ingredientJsonFile, ingredientFileContent);
    fileManagement.writeFile(mealJsonFile, mealFileContent);
  }
}
