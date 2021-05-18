import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Model/EnvironmentConfig.dart' as config;
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/CreateElementTextField.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyDeleteIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import '../../Handlers/SharedValueHandler.dart';
import '../../Model/Extra.dart';

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
  Future _currencyChosenFuture;
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
    _currencyChosenFuture =
        _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK');
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
                      future: _currencyChosenFuture,
                      initialData: '',
                      builder: (context, currencySnapshot) {
                        if (currencySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return MyLoadingCircle(500);
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CreateElementTextField(
                              title: 'Name',
                              myValue: _name,
                              textEditingController: _nameController,
                              validate: validateString,
                              setValue: (value) => _name = value,
                            ),
                            CreateElementTextField(
                              title: 'Buy Price',
                              myValue: _buyPrice,
                              textEditingController: _buyPriceController,
                              validate: validateDouble,
                              setValue: (value) => _buyPrice = value,
                              suffixText: ',- ${currencySnapshot.data}',
                              textInputType: TextInputType.numberWithOptions(
                                  decimal: true),
                            ),
                            CreateElementTextField(
                              title: 'Sale Price',
                              myValue: _salePrice,
                              textEditingController: _salePriceController,
                              validate: validateDouble,
                              setValue: (value) => _salePrice = value,
                              suffixText: ',- ${currencySnapshot.data}',
                              textInputType: TextInputType.numberWithOptions(
                                  decimal: true),
                            ),
                            MyIconButton(
                              tileTitle: 'Save Extra',
                              tileIcon: Icon(Icons.save),
                              myOnPressed: () => _saveExtra(),
                              compact: true,
                            ),
                            widget.editMode ?? false
                                ? MyDeleteIconButton(
                                    myOnPressed: () =>
                                        _deleteExtraDialog(context))
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

  //Delete extra menu box
  _deleteExtraDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: 'Delete element',
          content:
              'This cannot be undone, are you sure you want to delete this element?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          myOnPressed: () => _deleteExtra(context),
        );
      },
    );
  }

  void showCouldNotDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: 'Error',
          content:
              'Could not delete extra, because one or more menus are using it.',
          cancelText: 'Close',
          infoDialog: true,
        );
      },
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

//Save to File
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
      showCouldNotDeleteDialog();
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
