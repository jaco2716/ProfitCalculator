import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Model/EnvironmentConfig.dart' as config;
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import '../../Handlers/SharedValueHandler.dart';
import '../Model/Extra.dart';

class CreateExtra extends StatefulWidget {
  final bool editMode;
  final Extra editExtra;

  CreateExtra({this.editMode, this.editExtra});

  @override
  _CreateExtraState createState() => _CreateExtraState();
}

class _CreateExtraState extends State<CreateExtra> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyDialog = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _buyPriceController = TextEditingController();
  TextEditingController _salePriceController = TextEditingController();
  String _name = '';
  String _salePrice = '';
  String _buyPrice = '';
  String extraJsonFile = config.extraJsonFile;
  String menuJsonFile = config.menuJsonFile;
  List<Extra> extraList = <Extra>[];

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  void initState() {
    super.initState();

    initEditMode();
  }

//Check if extra is being edited and then insert object
  initEditMode() {
    String tempSalePrice;
    String tempBuyPrice;
    if (widget.editMode ?? false) {
      _name = widget.editExtra.name;
      tempSalePrice = widget.editExtra.salePrice.toString();
      tempBuyPrice = widget.editExtra.costPrice.toString();
      _salePrice = tempSalePrice.replaceAll('.', ',');
      _buyPrice = tempBuyPrice.replaceAll('.', ',');
      _nameController.text = _name;
      _salePriceController.text = _salePrice;
      _buyPriceController.text = _buyPrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc(
          widget.editMode ?? false ? 'Edit Extra' : 'Create Extra'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              padding: EdgeInsets.all(30),
              child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: FutureBuilder(
                      future: _sharedValueHandler.getStringSharedP(
                          'CurrencyChosen', 'DKK'),
                      initialData: '',
                      builder: (context, currencySnapshot) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Name',
                              ),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              validator: (value) => validateString(value),
                              onSaved: (value) => _name = value,
                              onFieldSubmitted: (value) => changeFocus(),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              // width: MediaQuery.of(context).size.width - 110,
                              child: TextFormField(
                                controller: _buyPriceController,
                                decoration: InputDecoration(
                                  suffixText: ',- ${currencySnapshot.data}',
                                  border: OutlineInputBorder(),
                                  labelText: 'Buy Price',
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,.]'))
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (value) => validateDouble(value),
                                onSaved: (value) => _buyPrice = value,
                                onFieldSubmitted: (value) => changeFocus(),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              // width: MediaQuery.of(context).size.width - 110,
                              child: TextFormField(
                                controller: _salePriceController,
                                decoration: InputDecoration(
                                  suffixText: ',- ${currencySnapshot.data}',
                                  border: OutlineInputBorder(),
                                  labelText: 'Sale Price',
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,.]'))
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (value) => validateDouble(value),
                                onSaved: (value) => _salePrice = value,
                                onFieldSubmitted: (value) => changeFocus(),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                width: 200,
                                child: RaisedButton.icon(
                                    icon: Icon(Icons.save),
                                    padding: EdgeInsets.all(15),
                                    label: Text('Save Extra'),
                                    onPressed: () => _saveExtra())),
                            SizedBox(
                              height: 10,
                            ),
                            widget.editMode ?? false
                                ? IconButton(
                                    padding: EdgeInsets.all(40),
                                    iconSize: 40,
                                    color: Colors.red,
                                    icon: Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteExtraDialog(context),
                                  )
                                : Center(),
                            SizedBox(
                              height: 400,
                            )
                          ],
                        );
                      })),
            ),
          ),
        ),
      ),
    );
  }

//create object and save
  _saveExtra() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      String tempBuyPrice = _buyPrice.replaceAll(',', '.');
      double finalBuyPrice = double.parse(tempBuyPrice);
      String tempSalePrice = _salePrice.replaceAll(',', '.');
      double finalSalePrice = double.parse(tempSalePrice);
//Create new id or use edit Extra id
      int newID;
      if (widget.editMode ?? false)
        newID = widget.editExtra.id;
      else
        newID = DateTime.now().millisecondsSinceEpoch;

//Create object
      Extra newExtra =
          Extra(newID, _name, finalSalePrice, finalBuyPrice, amount: 1);

      bool saveSucess = false;
//Save Extra to json file.

      saveSucess = await _saveExtraToFile(newExtra);

//Show error or succes message
      if (saveSucess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_name + ' has been saved.'),
        ));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong, try again.'),
        ));
      }
    }
  }

//Save to firestore database
  Future<bool> _saveExtraToFile(Extra newExtra) async {
    try {
      String fileContent = await fileManagement.readFile(extraJsonFile);
      List<Extra> allExtrasFromFile = objManager.jsonToListExtra(fileContent);

      if (widget.editMode ?? false) {
        int editExtraIndex = allExtrasFromFile
            .indexWhere((element) => element.id == newExtra.id);
        allExtrasFromFile[editExtraIndex] = newExtra;

        String menuFileContent = await fileManagement.readFile(menuJsonFile);
        List<Menu> allMenusFromFile =
            objManager.jsonToListMenu(menuFileContent);

        //Update data of extras in menus
        allMenusFromFile.forEach((menu) {
          int menuEditIndex =
              menu.extras.indexWhere((element) => element.id == newExtra.id);
          if (menuEditIndex != -1) {
            Extra newExtraWGrams = newExtra;
            int amount = menu.extras[menuEditIndex].amount;
            newExtraWGrams.amount = amount;
            menu.extras[menuEditIndex] = newExtraWGrams;
          }
        });
        fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
      } else {
        allExtrasFromFile.add(newExtra);
      }
      fileManagement.writeFile(extraJsonFile, jsonEncode(allExtrasFromFile));
    } catch (error) {
      print('Error saving extra: $error');
      return false;
    }
    return true;
  }

  //Delete extra menu box
  _deleteExtraDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete element'),
          content: Text(
              'This cannot be undone, are you sure you want to delete this element?'),
          actions: [
            RaisedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text('Yes'),
              color: Colors.red,
              onPressed: () => _deleteExtra(context),
            )
          ],
        );
      },
    );
  }

  _deleteExtra(BuildContext context) async {
    String extraFileContent = await fileManagement.readFile(extraJsonFile);
    List<Extra> allExtrasFromFile =
        objManager.jsonToListExtra(extraFileContent);

    String menuFileContent = await fileManagement.readFile(menuJsonFile);
    List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
    int extraInMenuFoundIndex = -1;
    if (allMenusFromFile != null) {
      for (var m in allMenusFromFile) {
        extraInMenuFoundIndex =
            m.extras.indexWhere((i) => i.id == widget.editExtra.id);
        if (extraInMenuFoundIndex >= 0) {
          break;
        }
      }
    }

    if (extraInMenuFoundIndex != -1) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Could not delete extra, because one or more menus are using it.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok'))
            ],
          );
        },
      );
    } else {
      int deleteIndex = allExtrasFromFile
          .indexWhere((element) => element.id == widget.editExtra.id);
      allExtrasFromFile.removeAt(deleteIndex);

      fileManagement.writeFile(extraJsonFile, jsonEncode(allExtrasFromFile));
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.editExtra.name} was deleted.')));
    }
  }

//change focus to remove keyboard when background is tapped
  void changeFocus() {
    FocusScope.of(context).nextFocus();
  }

//validate that input is not empty
  String validateString(String value) {
    return value.isEmpty ? 'Required' : null;
  }

//validate that the number is valid
  String validateDouble(String value) {
    try {
      value = value.replaceAll(',', '.');
      double.parse(value);
      return null;
    } catch (error) {
      return "Invalid number.";
    }
  }
}
