import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';

import '../MyWidgets/MyAppBarWithCalc.dart';
import '../MyWidgets/MyLoadingCircle.dart';

class VATChangePage extends StatefulWidget {
  @override
  _VATChangePageState createState() => _VATChangePageState();
}

class _VATChangePageState extends State<VATChangePage> {
  final TextEditingController vatTec = TextEditingController();
  final TextEditingController hourPriceTec = TextEditingController();
  String dropdownValue = 'USD';
  List<bool> initialLoads = [true, true, true];
  String vatErrorText;
  String hourErrorText;

  // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('VAT, Currency & Hourly rate'),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Here you can change the hourly rate that is used to calculate the expense of time to make your meals.\nAdditionaly you can change the VAT and Currency that is relevant in your region.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              FutureBuilder(
                future: _sharedValueHandler.getIntSharedP('hourPrice', 100),
                initialData: '',
                builder:
                    (BuildContext context, AsyncSnapshot hourPriceSnapshot) {
                  if (hourPriceSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return MyLoadingCircle(500);
                  }
                  if (initialLoads[0]) {
                    hourPriceTec.text = hourPriceSnapshot.data.toString();
                    initialLoads[0] = false;
                  }
                  // if (initialLoads[0]) {
                  // hourPriceTec.text = hourPriceSnapshot.data.toString();
                  //   initialLoads[0] = false;
                  // }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        // onChanged: (value) {
                        //   tec.text = value;
                        // },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefix: Text('Hourly rate:   '),
                          errorText: hourErrorText,
                        ),
                        controller: hourPriceTec,
                        // decoration: InputDecoration(hintText: 'VAT in %'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                      ),
                    ),
                  );
                },
              ),
              FutureBuilder(
                future: _sharedValueHandler.getIntSharedP('VATPercent', 25),
                initialData: '',
                builder: (BuildContext context, AsyncSnapshot vatSnapshot) {
                  if (vatSnapshot.connectionState == ConnectionState.waiting) {
                    return MyLoadingCircle(500);
                  }
                  if (initialLoads[1]) {
                    vatTec.text = vatSnapshot.data.toString();
                    initialLoads[1] = false;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        // onChanged: (value) {
                        //   tec.text = value;
                        // },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefix: Text('VAT in %:       '),
                          errorText: vatErrorText,
                        ),

                        controller: vatTec,
                        // decoration: InputDecoration(hintText: 'VAT in %'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                      ),
                    ),
                  );
                },
              ),
              FutureBuilder(
                  future: _sharedValueHandler.getStringSharedP(
                      'CurrencyChosen', 'DKK'),
                  builder: (context, currencySnapshot) {
                    if (currencySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return MyLoadingCircle(500);
                    }

                    if (initialLoads[2]) {
                      initialLoads[2] = false;
                      dropdownValue = currencySnapshot.data;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          // height: 60,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.black38)),
                          // color: Colors.grey[300],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Currency:           '),
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
                  String hourPrice = hourPriceTec.text;
                  String currencytext = dropdownValue;
                  int vatInt = int.parse(vattext);
                  int hourPriceInt = int.parse(hourPrice);
                  bool validateSuccess = true;
                  if (vatInt <= 0) {
                    vatErrorText = 'VAT must be grater than 0';
                    validateSuccess = false;
                  }
                  if (hourPriceInt <= 0) {
                    hourErrorText = 'Hourly rate must be grater than 0';
                    validateSuccess = false;
                  }
                  if (!validateSuccess) {
                    setState(() {});
                    return;
                  }

                  bool saveSucces = await _sharedValueHandler.saveIntSharedP(
                      vatInt, 'VATPercent');
                  saveSucces = await _sharedValueHandler.saveIntSharedP(
                      hourPriceInt, 'hourPrice');
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
      ),
    );
  }

  Widget drawerListTile(
      {Icon tileIcon, String tileTitle, void Function() myOnPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
