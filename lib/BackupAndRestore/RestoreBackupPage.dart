import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import '../Model/EnvironmentConfig.dart' as config;
import '../MyAppBarWithCalc.dart';

class RestoreBackupPage extends StatelessWidget {
  final FileManagement fileManagement = FileManagement();
  final String mealJsonFile = config.mealJsonFile;
  final String ingredientJsonFile = config.ingredientJsonFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('Restore Backup'),
      body: Container(
        width: double.infinity,
        // color: Colors.amber,
        padding: EdgeInsets.all(20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Here you can change what menu you are currently using, and allows you to edit menus individually.',
                textAlign: TextAlign.center,
              ),
            ),
            saveSlotButton('Restore from Slot 1', '02/03/2021', 1),
            saveSlotButton('Restore from Slot 2', 'Empty', 2),
            saveSlotButton('Restore from Slot 3', 'Empty', 3),
            saveSlotButton('Restore from Slot 4', 'Empty', 4),
            saveSlotButton('Restore from Slot 5', 'Empty', 5),
          ],
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
        label: Text('$title \nLast save: $dateLastSaved'),
        onPressed: () async {
          // String ingredientFileContent = await fileManagement.readFile(ingredientJsonFile);
          // fileManagement.writeFile('$ingredientJsonFile$index', ingredientFileContent);
          // String mealFileContent = await fileManagement.readFile(mealJsonFile);
          // fileManagement.writeFile('$mealJsonFile$index', mealFileContent);

          String ingredientFileContent =
              await fileManagement.readFile('$ingredientJsonFile$index');
          String mealFileContent =
              await fileManagement.readFile('$mealJsonFile$index');

          fileManagement.writeFile(ingredientJsonFile, ingredientFileContent);
          fileManagement.writeFile(mealJsonFile, mealFileContent);

          print(mealFileContent);
        },
      ),
    );
  }
}
