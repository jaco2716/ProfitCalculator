import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ValidateValues.dart';
import 'package:profit_calculator/Model/Catering.dart';
import 'package:profit_calculator/Model/EnvironmentConfig.dart' as config;
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/CreateElementTextField.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/Pages/ExtraPages/SingleExtraPage.dart';
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
  TextEditingController _nameController = TextEditingController();
  TextEditingController _buyPriceController = TextEditingController();
  TextEditingController _salePriceController = TextEditingController();
  Future _currencyChosenFuture;
  String _name = '';
  String _salePrice = '';
  String _buyPrice = '';
  String extraJsonFile = config.extraJsonFile;
  String menuJsonFile = config.menuJsonFile;
  String cateringJsonFile = config.cateringJsonFile;
  List<Extra> extraList = <Extra>[];

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  final ValidateValues _validateValues = ValidateValues();

  @override
  void initState() {
    super.initState();
    _currencyChosenFuture = _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK');
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
      appBar: MyAppBarWithCalc(widget.editMode ?? false ? 'Edit Extra' : 'Create Extra'),
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
                        if (currencySnapshot.connectionState == ConnectionState.waiting) {
                          return MyLoadingCircle(500);
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CreateElementTextField(
                              title: 'Name',
                              myValue: _name,
                              textEditingController: _nameController,
                              validate: _validateValues.validateString,
                              setValue: (value) => _name = value,
                            ),
                            CreateElementTextField(
                              title: 'Buy Price',
                              myValue: _buyPrice,
                              textEditingController: _buyPriceController,
                              validate: _validateValues.validateDouble,
                              setValue: (value) => _buyPrice = value,
                              allowedInput: r'[0-9.,]',
                              suffixText: ',- ${currencySnapshot.data}',
                              textInputType: TextInputType.numberWithOptions(decimal: true),
                            ),
                            CreateElementTextField(
                              title: 'Sale Price',
                              myValue: _salePrice,
                              textEditingController: _salePriceController,
                              validate: _validateValues.validateDouble,
                              setValue: (value) => _salePrice = value,
                              allowedInput: r'[0-9.,]',
                              suffixText: ',- ${currencySnapshot.data}',
                              textInputType: TextInputType.numberWithOptions(decimal: true),
                            ),
                            MyIconButton(
                              tileTitle: 'Save Extra',
                              tileIcon: Icon(Icons.save),
                              myOnPressed: () => _saveExtra(),
                              compact: true,
                            ),
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
      Extra newExtra = Extra(newID, _name, finalSalePrice, finalBuyPrice, amount: 1);
      bool saveSucess = false;
//Save Extra to json file.
      saveSucess = await _saveExtraToFile(newExtra);

//Show error or succes message
      if (saveSucess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_name + ' has been saved.'),
        ));

        if (widget.editMode ?? false) {
          Navigator.of(context).pop(newExtra);
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SingleExtraPage(newExtra)));
        }
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
        int editExtraIndex = allExtrasFromFile.indexWhere((element) => element.id == newExtra.id);
        allExtrasFromFile[editExtraIndex] = newExtra;

        String menuFileContent = await fileManagement.readFile(menuJsonFile);
        List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
        String cateringFileContent = await fileManagement.readFile(cateringJsonFile);
        List<Catering> allCateringsFromFile = objManager.jsonToListCatering(cateringFileContent);

        //Update data of extras in menus
        _updateExtrasInFile(allMenusFromFile, newExtra);
        _updateExtrasInFile(allCateringsFromFile, newExtra);
        allCateringsFromFile.forEach((catering) {
          _updateExtrasInFile(catering.menus, newExtra);
        });
        fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
        fileManagement.writeFile(cateringJsonFile, jsonEncode(allCateringsFromFile));
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

  _updateExtrasInFile(List<dynamic> updateElementList, Extra newExtra) {
    updateElementList.forEach((element) {
      int elementEditIndex = element.extras.indexWhere((element) => element.id == newExtra.id);
      if (elementEditIndex != -1) {
        Extra newExtraWAmount = Extra.clone(newExtra);
        newExtraWAmount.amount = element.extras[elementEditIndex].amount;
        element.extras[elementEditIndex] = newExtraWAmount;
      }
    });
  }
}
