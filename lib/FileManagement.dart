import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
      if(fileExists){
        jsonContents = await file.readAsString();
      }else {
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
}
