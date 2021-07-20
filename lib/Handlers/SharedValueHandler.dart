import 'package:shared_preferences/shared_preferences.dart';

class SharedValueHandler {

  Future<int> getIntSharedP(String variableName, int defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int valueInt = (prefs.getInt(variableName) ?? defaultValue);
    return valueInt;
  }

  Future<bool> saveIntSharedP(int value, String variableName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(variableName, value);
      return true;
    } catch (e) {
    print('Error saving $variableName: $e');
      return false;
    }
  }

  Future<String> getStringSharedP(String variableName, String defaultValue) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(variableName) ?? defaultValue;
    return value;
  }

  Future<bool> saveStringSharedP(String value, String variableName) async {
    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(variableName, value);
      return true;
    } catch (e) {
    print('Error saving $variableName: $e');
      return false;
    }
  }
}
