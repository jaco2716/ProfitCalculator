import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';

import 'MyAppBarWithCalc.dart';

class VATChangePage extends StatefulWidget {
  @override
  _VATChangePageState createState() => _VATChangePageState();
}

class _VATChangePageState extends State<VATChangePage> {
  final TextEditingController vatTec = TextEditingController();
  String dropdownValue = 'USD';
  List<bool> initialLoads = [true, true];

  // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('Set VAT & Currency'),
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
            FutureBuilder(
              future: _sharedValueHandler.getIntSharedP('VATPercent', 25),
              initialData: '',
              builder: (BuildContext context, AsyncSnapshot vatSnapshot) {
                if(vatSnapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
                if (initialLoads[0]) {
                  print('vatSnapshot');
                  print(vatSnapshot);
                  vatTec.text = vatSnapshot.data.toString();
                  initialLoads[0] = false;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                      color: Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('VAT in %:       '),
                            Expanded(
                              child: TextField(
                                // onChanged: (value) {
                                //   tec.text = value;
                                // },

                                controller: vatTec,
                                // decoration: InputDecoration(hintText: 'VAT in %'),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]'))
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              },
            ),
            FutureBuilder(
                future: _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK'),
                builder: (context, currencySnapshot) {
                if(currencySnapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();

                  if (initialLoads[1]) {
                    initialLoads[1] = false;
                    dropdownValue = currencySnapshot.data;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                        color: Colors.grey[300],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Currency:       '),
                                Expanded(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: dropdownValue,
                                    // icon: const Icon(Icons.arrow_downward),
                                    // iconSize: 24,
                                    // elevation: 16,
                                    // style: const TextStyle(color: Colors.grey),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.blue,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue = newValue;
                                      });
                                    },
                                    items: <String>[
                                      'USD',
                                      'DKK',
                                      'GBP',
                                      'EUR',
                                      'JPY',
                                      'CHF',
                                      'CAD',
                                      'AUD'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ]),
                        )),
                  );
                }),
            drawerListTile(
              tileIcon: Icon(Icons.save),
              tileTitle: "Save",
              myOnPressed: () async {
                String vattext = vatTec.text;
                String currencytext = dropdownValue;
                int valueInt = int.parse(vattext);
                bool saveSucces = await _sharedValueHandler.saveIntSharedP(
                    valueInt, 'CurrencyChosen');
                saveSucces = await _sharedValueHandler.saveStringSharedP(
                    currencytext, 'CurrencyChosen');
                if (saveSucces) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'VAT & Currency has been set to $vattext% & $currencytext.')));
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
}
