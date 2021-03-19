import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VATChangePage extends StatelessWidget {
  final TextEditingController tec = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change VAT'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Icon(
                  Icons.attach_money,
                  size: 80,
                  color: Colors.blue[200],
                ),
              ),
            ),
            Container(
              height: 40,
              child: FutureBuilder(
                future: getVATSharedP(),
                initialData: '...',
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Text(
                    'VAT is set to ${snapshot.data}%.',
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                  color: Colors.grey[300],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      // onChanged: (value) {
                      //   tec.text = value;
                      // },
                      controller: tec,
                      decoration: InputDecoration(hintText: 'VAT in %'),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                    ),
                  )),
            ),
            drawerListTile(
              tileIcon: Icon(Icons.save),
              tileTitle: "Save",
              myOnPressed: () async {
                String vattext = tec.text;
                bool saveSucces = await saveVATSharedP(vattext);
                if (saveSucces) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('VAT has been set to $vattext%.')));
                      Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Something went wrong.')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

//List tile for every page to go to.
  Widget drawerListTile(
      {Icon tileIcon, String tileTitle, void Function() myOnPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(
        height: 60,
        child: ElevatedButton.icon(
            label: Text('Save'),
            icon: Icon(Icons.save),
            onPressed: () {
              myOnPressed();
              // Navigator.pop(context);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => navigationPage));
            }),
      ),
    );
  }

  Future<int> getVATSharedP() async {
    final SharedPreferences prefs = await _prefs;
    int vat = (prefs.getInt('VATPercent') ?? 0);
    return vat;
  }

  Future<bool> saveVATSharedP(String vattext) async {
    try {
      int vat = int.parse(vattext);
      final SharedPreferences prefs = await _prefs;
      await prefs.setInt('VATPercent', vat);
      return true;
    } catch (e) {
      print('Error saving VAT: $e');
      return false;
    }
  }
}
