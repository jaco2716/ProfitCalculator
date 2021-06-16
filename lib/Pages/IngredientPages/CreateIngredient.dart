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
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/MeasureUnitButtonGridTile.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyDeleteIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import '../../Model/Ingredient.dart';
import '../../Model/Meal.dart';
import '../../Handlers/SharedValueHandler.dart';

class CreateIngredient extends StatefulWidget {
  final bool editMode;
  final Ingredient editIngredient;

  CreateIngredient({this.editMode, this.editIngredient});

  @override
  _CreateIngredientState createState() => _CreateIngredientState();
}

class _CreateIngredientState extends State<CreateIngredient> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyDialog = GlobalKey<FormState>();
  TextEditingController _kgPriceController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  Future _currencyChosenFuture;
  String _name = '';
  String _kgPrice = '';
  String _measureUnit = 'g';
  String _tempMeasureUnit;
  String _amountValue = '';
  String _amountPrice = '';
  String _currencyChosen = 'DKK';

  String ingredientJsonFile = config.ingredientJsonFile;
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;
  String cateringJsonFile = config.cateringJsonFile;
  List<Ingredient> ingredientsList = <Ingredient>[];

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

//Check if ingredient is being edited and then insert object
  initEditMode() {
    String tempKg;
    if (widget.editMode ?? false) {
      _name = widget.editIngredient.name;
      tempKg = widget.editIngredient.kgPrice.toString();
      _kgPrice = tempKg.replaceAll('.', ',');
      _measureUnit = widget.editIngredient.measureUnit;
      _nameController.text = _name;
      _kgPriceController.text = _kgPrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc(widget.editMode ?? false ? 'Edit Ingredient' : 'Create Ingredient'),
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
                      _currencyChosen = currencySnapshot.data;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CreateElementTextField(
                            title: 'Name *',
                            myValue: _name,
                            textEditingController: _nameController,
                            validate: _validateValues.validateString,
                            setValue: (value) => _name = value,
                          ),
                          CreateElementTextField(
                            title: 'Kg Price / Liter Price *',
                            myValue: _kgPrice,
                            textEditingController: _kgPriceController,
                            validate: _validateValues.validateDouble,
                            setValue: (value) => _kgPrice = value,
                            readOnly: true,
                            onTap: () => inputAmuntDialog(),
                            suffixText: _measureUnit == 'Kg' || _measureUnit == 'g' ? '$_currencyChosen/Kg' : '$_currencyChosen/Liter',
                          ),
                          MyIconButton(
                            tileIcon: Icon(Icons.save),
                            compact: true,
                            tileTitle: 'Save Ingredient',
                            myOnPressed: () => _saveIngredient(),
                          ),
                          widget.editMode ?? false ? MyDeleteIconButton(myOnPressed: () => _deleteIngredientDialog(context)) : Center(),
                          SizedBox(
                            height: 400,
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Delete ingredient menu box
  _deleteIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: 'Delete Ingredient',
          content: 'This cannot be undone, are you sure you want to delete this ingredient?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          myOnPressed: () => _deleteIngredient(context),
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
          content: 'Could not delete ingredient, because one or more meals, menus or caterings are using it.',
          cancelText: 'Close',
          infoDialog: true,
        );
      },
    );
  }

  void inputAmuntDialog() {
    _tempMeasureUnit = _measureUnit;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 5),
            content: StatefulBuilder(builder: (BuildContext context, setModalState) {
              return Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKeyDialog,
                child: Container(
                  height: 225,
                  child: Column(
                    children: [
                      CreateElementTextField(
                        title: 'Price for amount',
                        myValue: _amountPrice,
                        suffixText: ',- $_currencyChosen',
                        textInputType: TextInputType.numberWithOptions(decimal: true),
                        allowedInput: r'[0-9.,]',
                        validate: (value) => _validateValues.validateDouble(value),
                        setValue: (value) => _amountPrice = value,
                      ),
                      CreateElementTextField(
                        title: 'Amount in $_tempMeasureUnit',
                        myValue: _amountValue,
                        suffixText: _tempMeasureUnit,
                        allowedInput: r'[0-9.,]',
                        textInputType: TextInputType.numberWithOptions(decimal: true),
                        validate: (value) => _validateValues.validateDouble(value),
                        setValue: (value) => _amountValue = value,
                      ),
                      MeasureUnitButtonGrid(
                          tempChosenUnit: _tempMeasureUnit,
                          dropDownValues: ["g", "ml", "Kg", "Liter"],
                          changeToValue: (value) {
                            setModalState(() {
                              changeMeasureUnitValue(value);
                            });
                          }),
                    ],
                  ),
                ),
              );
            }),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close')),
              ElevatedButton(
                onPressed: () => setAmountToKgPrice(),
                child: Text('Done'),
              )
            ],
          );
        }).then((value) {
      setState(() {});
    });
  }

//create object and save
  _saveIngredient() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      String tempKgPrice = _kgPrice.replaceAll(',', '.');
      double finalKgPrice = double.parse(tempKgPrice);
//Create new id or use edit ingredient id
      int newID;
      if (widget.editMode ?? false)
        newID = widget.editIngredient.id;
      else
        newID = DateTime.now().millisecondsSinceEpoch;

//Create object
      String _newMeasureUnit = _measureUnit == 'Kg' || _measureUnit == 'g' ? 'Kg' : 'Liter';
      Ingredient newIngredient = Ingredient(newID, _name, finalKgPrice, 4294198070, _newMeasureUnit);

      bool saveSucess = false;
//Save ingredient to json file.

      saveSucess = await _saveIngredientToFile(newIngredient);

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields')));
    }
  }

//Save to file storage
  Future<bool> _saveIngredientToFile(Ingredient newIngredient) async {
    try {
      String ingredientFileContent = await fileManagement.readFile(ingredientJsonFile);
      List<Ingredient> allIngredientsFromFile = objManager.jsonToListIngredient(ingredientFileContent);

      if (widget.editMode ?? false) {
        String mealFileContent = await fileManagement.readFile(mealJsonFile);
        String menuFileContent = await fileManagement.readFile(menuJsonFile);
        String cateringFileContent = await fileManagement.readFile(cateringJsonFile);
        List<Meal> allMealsFromFile = objManager.jsonToListMeal(mealFileContent);
        List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
        List<Catering> allCateringsFromFile = objManager.jsonToListCatering(cateringFileContent);

        int ingredientEditIndex = allIngredientsFromFile.indexWhere((element) => element.id == newIngredient.id);
        allIngredientsFromFile[ingredientEditIndex] = newIngredient;

        //Update data of ingredients in meals, menus and caterings
        _updateIngredientsInFile(allMealsFromFile, newIngredient);
        _updateIngredientsInFile(allMenusFromFile, newIngredient);
        allMenusFromFile.forEach((menu) {
          _updateIngredientsInFile(menu.meals, newIngredient);
        });
        _updateIngredientsInFile(allCateringsFromFile, newIngredient);
        allCateringsFromFile.forEach((catering) {
          _updateIngredientsInFile(catering.meals, newIngredient);
          _updateIngredientsInFile(catering.menus, newIngredient);
          catering.menus.forEach((menu) {
            _updateIngredientsInFile(menu.meals, newIngredient);
          });
        });

        fileManagement.writeFile(mealJsonFile, jsonEncode(allMealsFromFile));
        fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
        fileManagement.writeFile(cateringJsonFile, jsonEncode(allCateringsFromFile));
      } else {
        allIngredientsFromFile.add(newIngredient);
      }
      fileManagement.writeFile(ingredientJsonFile, jsonEncode(allIngredientsFromFile));
    } catch (error) {
      print('Error saving ingredient: $error');
      return false;
    }
    return true;
  }

  _updateIngredientsInFile(List<dynamic> updateElementList, Ingredient newIngredient) {
    updateElementList.forEach((element) {
      int elementEditIndex = element.ingredients.indexWhere((element) => element.id == newIngredient.id);
      if (elementEditIndex != -1) {
        Ingredient newIngredientWGrams = Ingredient.clone(newIngredient);
        newIngredientWGrams.amountInGrams = element.ingredients[elementEditIndex].amountInGrams;
        element.ingredients[elementEditIndex] = newIngredientWGrams;
      }
    });
  }

  _deleteIngredient(BuildContext context) async {
    String ingredientFileContent = await fileManagement.readFile(ingredientJsonFile);
    List<Ingredient> allIngredientsFromFile = objManager.jsonToListIngredient(ingredientFileContent);

    int ingredientFoundIndex = -1;
    String mealFileContent = await fileManagement.readFile(mealJsonFile);
    List<Meal> allMealsFromFile = objManager.jsonToListMeal(mealFileContent);
    if (allMealsFromFile != null) {
      for (var m in allMealsFromFile) {
        ingredientFoundIndex = m.ingredients.indexWhere((i) => i.id == widget.editIngredient.id);
        if (ingredientFoundIndex >= 0) {
          break;
        }
      }
    }

    String menuFileContent = await fileManagement.readFile(menuJsonFile);
    List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
    if (allMenusFromFile != null) {
      for (var m in allMenusFromFile) {
        ingredientFoundIndex = m.ingredients.indexWhere((i) => i.id == widget.editIngredient.id);
        if (ingredientFoundIndex >= 0) {
          break;
        }
      }
    }

    String cateringFileContent = await fileManagement.readFile(cateringJsonFile);
    List<Catering> allCateringsFromFile = objManager.jsonToListCatering(cateringFileContent);
    if (allCateringsFromFile != null) {
      for (var m in allCateringsFromFile) {
        ingredientFoundIndex = m.ingredients.indexWhere((i) => i.id == widget.editIngredient.id);
        if (ingredientFoundIndex >= 0) {
          break;
        }
      }
    }

    if (ingredientFoundIndex != -1) {
      Navigator.of(context).pop();
      showCouldNotDeleteDialog();
    } else {
      int deleteIndex = allIngredientsFromFile.indexWhere((element) => element.id == widget.editIngredient.id);
      allIngredientsFromFile.removeAt(deleteIndex);

      fileManagement.writeFile(ingredientJsonFile, jsonEncode(allIngredientsFromFile));
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.editIngredient.name} was deleted.')));
    }
  }

  void setAmountToKgPrice() {
    if (_formKeyDialog.currentState.validate()) {
      _formKeyDialog.currentState.save();
      String tempAmountValue = _amountValue.replaceAll(',', '.');
      String tempAmountPrice = _amountPrice.replaceAll(',', '.');
      double newAmountValue = double.parse(tempAmountValue);
      double newAmountPrice = double.parse(tempAmountPrice);
      double _newkgPrice = newAmountPrice / newAmountValue;
      if (_tempMeasureUnit == 'g' || _tempMeasureUnit == 'ml') {
        _newkgPrice *= 1000;
      }
      _newkgPrice = (_newkgPrice * 100).roundToDouble() / 100;
      _kgPrice = _newkgPrice.toString().replaceAll('.', ',');
      _kgPriceController.text = _kgPrice;
      _measureUnit = _tempMeasureUnit;
      Navigator.of(context).pop();
    }
  }

  void changeMeasureUnitValue(String value) {
    _tempMeasureUnit = value;
  }
}


//TODO update elements in file, and check if can delete.