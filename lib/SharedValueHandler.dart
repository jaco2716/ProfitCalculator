import 'package:shared_preferences/shared_preferences.dart';

class SharedValueHandler {

  Future<int> getVATSharedP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int vat = (prefs.getInt('VATPercent') ?? 25);
    return vat;
  }

  Future<bool> saveVATSharedP(String vattext) async {
    try {
      int vat = int.parse(vattext);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('VATPercent', vat);
      return true;
    } catch (e) {
      print('Error saving VAT: $e');
      return false;
    }
  }
}
