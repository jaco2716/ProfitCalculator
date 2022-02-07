import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Handlers/ValidateValues.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/CreateElementTextField.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';

import '../MyWidgets/MyAppBarWithCalc.dart';
import '../MyWidgets/MyLoadingCircle.dart';

class VATChangePage extends StatefulWidget {
  @override
  _VATChangePageState createState() => _VATChangePageState();
}

class _VATChangePageState extends State<VATChangePage> {
  final TextEditingController vatTec = TextEditingController();
  final TextEditingController hourPriceTec = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future _currencyChosenFuture;
  Future _vatPercentFuture;
  Future _hourlyPriceFuture;
  String dropdownValue = 'USD';
  List<bool> initialLoads = [true, true, true];
  String vatErrorText;
  String hourErrorText;

  String _hourlyRate = '';
  String _vatPercent = '';
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  final ValidateValues _validateValues = ValidateValues();

  @override
  void initState() {
    super.initState();
    _currencyChosenFuture =
        _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK');
    _hourlyPriceFuture = _sharedValueHandler.getIntSharedP('hourPrice', 100);
    _vatPercentFuture = _sharedValueHandler.getIntSharedP('VATPercent', 25);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('VAT, Currency & Hourly rate'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
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
                    future: _hourlyPriceFuture,
                    initialData: '',
                    builder: (BuildContext context,
                        AsyncSnapshot hourPriceSnapshot) {
                      if (hourPriceSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return MyLoadingCircle(500);
                      }
                      if (initialLoads[0]) {
                        hourPriceTec.text = hourPriceSnapshot.data.toString();
                        initialLoads[0] = false;
                      }
                      return CreateElementTextField(
                        title: 'Hourly rate',
                        myValue: _hourlyRate,
                        suffixText: dropdownValue,
                        allowedInput: r'[0-9]',
                        textEditingController: hourPriceTec,
                        textInputType: TextInputType.number,
                        validate: (value) => _validateValues.validateInt(value, aboveValue: 0),
                        setValue: (value) => _hourlyRate = value,
                      );
                    },
                  ),
                  FutureBuilder(
                    future: _vatPercentFuture,
                    initialData: '',
                    builder: (BuildContext context, AsyncSnapshot vatSnapshot) {
                      if (vatSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return MyLoadingCircle(500);
                      }
                      if (initialLoads[1]) {
                        vatTec.text = vatSnapshot.data.toString();
                        initialLoads[1] = false;
                      }
                      return CreateElementTextField(
                        title: 'VAT in %',
                        myValue: _vatPercent,
                        suffixText: '%',
                        allowedInput: r'[0-9]',
                        textEditingController: vatTec,
                        textInputType: TextInputType.number,
                        validate: (value) => _validateValues.validateInt(value, aboveValue: 0),
                        setValue: (value) => _vatPercent = value,
                      );
                    },
                  ),
                  FutureBuilder(
                      future: _currencyChosenFuture,
                      builder: (context, currencySnapshot) {
                        if (currencySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return MyLoadingCircle(500);
                        }

                        if (initialLoads[2]) {
                          initialLoads[2] = false;
                          dropdownValue = currencySnapshot.data;
                        }

                        return Container(
                            height: 60,
                            margin: EdgeInsets.all(0),
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
                            ));
                      }),
                      Text('Changing the currency does not change any price values.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, letterSpacing: -0.5)),
                  SizedBox(
                    height: 10,
                  ),
                  MyIconButton(
                    tileIcon: Icon(Icons.save),
                    tileTitle: 'Save',
                    myOnPressed: () => saveVATetc(),
                    compact: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void saveVATetc() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      String currencytext = dropdownValue;
      int vatInt = int.parse(_vatPercent);
      int hourPriceInt = int.parse(_hourlyRate);

      bool saveSucces =
          await _sharedValueHandler.saveIntSharedP(vatInt, 'VATPercent');
      saveSucces =
          await _sharedValueHandler.saveIntSharedP(hourPriceInt, 'hourPrice');
      saveSucces = await _sharedValueHandler.saveStringSharedP(
          currencytext, 'CurrencyChosen');
      if (saveSucces) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Hourly Rate, VAT & Currency has been saved.')));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Something went wrong.')));
      }
    }
  }
}
