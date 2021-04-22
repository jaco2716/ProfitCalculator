import 'package:shared_preferences/shared_preferences.dart';

class SharedValueHandler {

  Future<int> getIntSharedP(String variableName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int vat = (prefs.getInt('VATPercent') ?? 25);
    return vat;
  }

  Future<bool> saveIntSharedP(String value, String variableName) async {
    try {
      int vat = int.parse(value);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('VATPercent', vat);
      return true;
    } catch (e) {
      print('Error saving VAT: $e');
      return false;
    }
  }

  Future<String> getStringSharedP(String variableName) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    String currency = prefs.getString('CurrencyChosen') ?? 'DKK';
    return currency;
  }

  Future<bool> saveStringSharedP(String value, String variableName) async {
    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('CurrencyChosen', value);
      return true;
    } catch (e) {
      print('Error saving VAT: $e');
      return false;
    }
  }
}
