import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../Model/EnvironmentConfig.dart' as config;

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
        if (fileName == config.ingredientJsonFile) {
          writeFile(
              fileName,
              '[{"id":1613445318000,"name":"Salt (Example)","kgPrice":29.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
                  '{"id":1613445319000,"name":"Pepper (Example)","kgPrice":89.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
                  '{"id":1613445320000,"name":"Rice (Example)","kgPrice":17.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
                  '{"id":1613445321000,"name":"Noodles (Example)","kgPrice":38.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
                  '{"id":1613445322000,"name":"Chicken (Example)","kgPrice":60.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
                  '{"id":1613445323000,"name":"Beef (Example)","kgPrice":60.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
                  '{"id":1613445324000,"name":"Chili (Example)","kgPrice":230.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
                  '{"id":1613445325000,"name":"Soya (Example)","kgPrice":60.0,"color":4294198070,"measureUnit":"Liter","amountInGrams":null}]');
          jsonContents = '[{"id":1613445318000,"name":"Salt (Example)","kgPrice":19.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
              '{"id":1613445319000,"name":"Pepper (Example)","kgPrice":39.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
              '{"id":1613445320000,"name":"Rice (Example)","kgPrice":12.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
              '{"id":1613445321000,"name":"Noodles (Example)","kgPrice":26.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
              '{"id":1613445322000,"name":"Chicken (Example)","kgPrice":30.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
              '{"id":1613445323000,"name":"Beef (Example)","kgPrice":40.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
              '{"id":1613445324000,"name":"Chili (Example)","kgPrice":130.0,"color":4294198070,"measureUnit":"Kg","amountInGrams":null},' +
              '{"id":1613445325000,"name":"Soya (Example)","kgPrice":40.0,"color":4294198070,"measureUnit":"Liter","amountInGrams":null}]';
        } else {
          writeFile(fileName, '');
          jsonContents = '';
        }
      }

      // print('Reading file $fileName.. Content: $jsonContents');

      return jsonContents;
    } catch (e) {
      // If encountering an error, return error message.
      return "Error getting content from $fileName";
    }
  }

  exportData(String fileName, String jsonString) async {
    final path = await _localPath;
    

    //mergedJson = ingredientJson + '&&&' + mealJson;
    writeFile(fileName, jsonString);

    await Share.shareFiles(
      ['$path/profCalculatorExportBackup.json'],
      subject: 'ProfCalculator Backup',
    );
  }

  // importData() async {
  //   final String ingredientJsonFile = config.ingredientJsonFile;
  //   final String mealJsonFile = config.mealJsonFile;

  //   FilePickerResult result = await FilePicker.platform
  //       .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
  //   File file;
  //   if (result != null) {
  //     file = File(result.files.single.path);
  //   //print(file.readAsString());
  //   } else {
  //     return;
  //   }
  //   String mergedJson = await file.readAsString();
  //   List<String> splitJson = mergedJson.split('&&&');
  //   String ingredientJson = splitJson[0];
  //   String mealJson = splitJson[1];
  //   writeFile(ingredientJsonFile, ingredientJson);
  //   writeFile(mealJsonFile, mealJson);
  // }
}
