import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'Model/EnvironmentConfig.dart' as config;

class FileManagement {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _getLocalFile(String fileName) async {
    final path = await _localPath;
    // print(path);
    return File('$path/$fileName.json');
  }

  Future<File> writeFile(String fileName, String jsonString) async {
    final file = await _getLocalFile(fileName);
    // print('Writing file $fileName');
    // Write the file.
    return file.writeAsString(jsonString);
  }

  Future<String> readFile(String fileName) async {
    try {
      final file = await _getLocalFile(fileName);

      // Read the file.
      bool fileExists = await file.exists();
      String jsonContents;
      if (fileExists) {
        jsonContents = await file.readAsString();
      } else {
        writeFile(fileName, '');
        jsonContents = '';
      }

      // print('Reading file $fileName.. Content: $jsonContents');

      return jsonContents;
    } catch (e) {
      // If encountering an error, return error message.
      return "Error getting content from $fileName";
    }
  }

  exportData(BuildContext context, String ingredientFileName,
      String mealFileName) async {
    final path = await _localPath;
    List<String> fileJsons = [];
    String mergedJson = '';

    String ingredientJson = await readFile(ingredientFileName);
    String mealJson = await readFile(mealFileName);

    mergedJson = ingredientJson + '&&&' + mealJson;
    writeFile('profitCalculatorBackup', mergedJson);

    await Share.shareFiles(
      ['$path/profitCalculatorBackup.json'],
      subject: 'Profit Calculator Backup',
    );
  }

  importData() async {
    final String ingredientJsonFile = config.ingredientJsonFile;
    final String mealJsonFile = config.mealJsonFile;

    FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    File file;
    if (result != null) {
      file = File(result.files.single.path);
      print(file.readAsString());
    } else {
      return;
    }
    String mergedJson = await file.readAsString();
    List<String> splitJson = mergedJson.split('&&&');
    String ingredientJson = splitJson[0];
    String mealJson = splitJson[1];
    writeFile(ingredientJsonFile, ingredientJson);
    writeFile(mealJsonFile, mealJson);
  }
}
