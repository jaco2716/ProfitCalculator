import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import '../../Model/EnvironmentConfig.dart' as config;
import 'package:intl/intl.dart';

class SaveBackupPage extends StatefulWidget {
  final bool restorePageSelected;

  SaveBackupPage(this.restorePageSelected);

  @override
  _SaveBackupPageState createState() => _SaveBackupPageState();
}

class _SaveBackupPageState extends State<SaveBackupPage> {
  final FileManagement fileManagement = FileManagement();

  final String ingredientJsonFile = config.ingredientJsonFile;
  final String extraJsonFile = config.extraJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  final String menuJsonFile = config.menuJsonFile;
  final String cateringJsonFile = config.cateringJsonFile;

  List<String> saveButtonDates = [];

  String saveButtonTitle;

  String pageTitle;

  DateFormat dateFormat = DateFormat("HH:mm - dd/MM/yyyy");

  SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  Widget build(BuildContext context) {
    if (widget.restorePageSelected) {
      saveButtonTitle = 'Restore from slot ';
      pageTitle = 'Restore your data from a previous save file.';
    } else {
      saveButtonTitle = 'Save to slot ';
      pageTitle = 'Save your data to a save file, and be able to restore it at a later time.';
    }

    return Scaffold(
      appBar: MyAppBarWithCalc(widget.restorePageSelected ? 'Restore Backup' : 'Save Backup'),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          // color: Colors.amber,
          padding: EdgeInsets.all(20),
          child: FutureBuilder(
              future: _sharedValueHandler.getStringSharedP('saveAndRestoreDates', 'Empty%Empty%Empty%Empty%Empty%'),
              builder: (context, saveAndRestoreSnapshot) {
                if (saveAndRestoreSnapshot.connectionState == ConnectionState.waiting) {
                  return MyLoadingCircle(500);
                }
                List<String> saveAndRestoreDates = saveAndRestoreSnapshot.data.toString().split('%');

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
                    saveSlotButton(saveButtonTitle, saveAndRestoreDates, 1),
                    saveSlotButton(saveButtonTitle, saveAndRestoreDates, 2),
                    saveSlotButton(saveButtonTitle, saveAndRestoreDates, 3),
                    saveSlotButton(saveButtonTitle, saveAndRestoreDates, 4),
                    saveSlotButton(saveButtonTitle, saveAndRestoreDates, 5),
                    // TextButton(
                    //   onPressed: () => restoreDataToExample(99),
                    //   child: Center(),
                    //   style: ElevatedButton.styleFrom(padding: EdgeInsets.all(80), primary: Colors.white10),
                    // ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget saveSlotButton(
    String title,
    List<String> dateLastSaved,
    int index,
  ) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 260,
      height: 80,
      child: ElevatedButton.icon(
        style: ButtonStyle(),
        icon: Icon(Icons.save),
        label: SizedBox(width: 180, child: Text('$title$index \nDate: ${dateLastSaved[index - 1]}')),
        onPressed: () {
          if (widget.restorePageSelected) {
            _saveAndRestoreDialog(context, 'Restore Save slot $index',
                'Are you sure you want to restore from this save file?\nThis will replace your current data, and it will be lost if you haven\'t saved it.',
                myOnPressed: () {
              restoreDataFromSaveFile(index);
            });
          } else {
            _saveAndRestoreDialog(context, 'Save to Save slot $index',
                'Are you sure you want to save your data to this save file?\nThis will replace the data on the save file with your current data.',
                myOnPressed: () {
              saveDataToSaveFile(index, dateLastSaved);
            });
          }
        },
      ),
    );
  }

  _saveAndRestoreDialog(BuildContext context, String title, String content, {void Function() myOnPressed}) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: title,
          content: content,
          cancelText: 'Cancel',
          confirmText: 'I\'m sure',
          myOnPressed: () {
            myOnPressed();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  saveDataToSaveFile(int index, List<String> datesList) async {
    try {
      DateTime newDate = DateTime.now();
      String dateString = dateFormat.format(newDate);
      datesList[index - 1] = dateString;
      String datesString = '';
      for (var i = 0; i < 5; i++) {
        datesString += datesList[i] + '%';
      }

      _sharedValueHandler.saveStringSharedP(datesString, 'saveAndRestoreDates');

      String ingredientFileContent = await fileManagement.readFile(ingredientJsonFile);
      String extraFileContent = await fileManagement.readFile(extraJsonFile);
      String mealFileContent = await fileManagement.readFile(mealJsonFile);
      String menuFileContent = await fileManagement.readFile(menuJsonFile);
      String cateringFileContent = await fileManagement.readFile(cateringJsonFile);

      fileManagement.writeFile('$ingredientJsonFile$index', ingredientFileContent);
      fileManagement.writeFile('$extraJsonFile$index', extraFileContent);
      fileManagement.writeFile('$mealJsonFile$index', mealFileContent);
      fileManagement.writeFile('$menuJsonFile$index', menuFileContent);
      fileManagement.writeFile('$cateringJsonFile$index', cateringFileContent);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data was saved to save slot $index'),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong, try again.'),
      ));
      print('Error saving data to file: ' + error.toString());
    }
  }

  restoreDataFromSaveFile(int index) async {
    try {
      String ingredientFileContent = await fileManagement.readFile('$ingredientJsonFile$index');
      String extraFileContent = await fileManagement.readFile('$extraJsonFile$index');
      String mealFileContent = await fileManagement.readFile('$mealJsonFile$index');
      String menuFileContent = await fileManagement.readFile('$menuJsonFile$index');
      String cateringFileContent = await fileManagement.readFile('$cateringJsonFile$index');

      fileManagement.writeFile(ingredientJsonFile, ingredientFileContent);
      fileManagement.writeFile(extraJsonFile, extraFileContent);
      fileManagement.writeFile(mealJsonFile, mealFileContent);
      fileManagement.writeFile(menuJsonFile, menuFileContent);
      fileManagement.writeFile(cateringJsonFile, cateringFileContent);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data was restored from save slot $index'),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong, try again.'),
      ));
      print('Error saving data to file: ' + error.toString());
    }
  }



  // restoreDataToExample(int index) async {
  //   try {
  //     String ingredientFileContent =
  //         '[{"id":1613445318000,"name":"Salt (Example)","kgPrice":29.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
  //             '{"id":1613445319000,"name":"Pepper (Example)","kgPrice":89.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
  //             '{"id":1613445320000,"name":"Rice (Example)","kgPrice":17.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
  //             '{"id":1613445321000,"name":"Noodles (Example)","kgPrice":38.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
  //             '{"id":1613445322000,"name":"Chicken (Example)","kgPrice":60.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
  //             '{"id":1613445323000,"name":"Beef (Example)","kgPrice":60.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
  //             '{"id":1613445324000,"name":"Chili (Example)","kgPrice":230.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
  //             '{"id":1613445325000,"name":"Soya (Example)","kgPrice":60.0,"color":4294198070,"measureUnit":"Liter","amountInGrams":null}]';
  //     String extraFileContent = '';
  //     String mealFileContent =
  //         '[{"id":1625054600790,"name":"Burger","salePrice":90.0,"ingredients":[{"id":1613445323000,"name":"Beef (Example)","kgPrice":60.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":400.0},{"id":1613445318000,"name":"Salt (Example)","kgPrice":29.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":10.0},{"id":1613445324000,"name":"Chili (Example)","kgPrice":230.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":20.0},{"id":1613445319000,"name":"Pepper (Example)","kgPrice":89.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":10.0}],"minutesToMake":10,"amount":null}]';
  //     String menuFileContent = '';
  //     String cateringFileContent = '';

  //     fileManagement.writeFile(ingredientJsonFile, ingredientFileContent);
  //     fileManagement.writeFile(extraJsonFile, extraFileContent);
  //     fileManagement.writeFile(mealJsonFile, mealFileContent);
  //     fileManagement.writeFile(menuJsonFile, menuFileContent);
  //     fileManagement.writeFile(cateringJsonFile, cateringFileContent);

  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Data was restored from save slot $index'),
  //     ));
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Something went wrong, try again.'),
  //     ));
  //     print('Error saving data to file: ' + error.toString());
  //   }
  // }
}
