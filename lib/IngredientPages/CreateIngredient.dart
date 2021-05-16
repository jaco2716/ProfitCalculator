import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Model/EnvironmentConfig.dart' as config;
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/CreateElementTextField.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/MeasureUnitButtonGridTile.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/MyWidgets/WideMenuIconButton.dart';
import '../Model/Ingredient.dart';
import '../Model/Meal.dart';
import '../Handlers/SharedValueHandler.dart';

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
  List<Ingredient> ingredientsList = <Ingredient>[];

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  void initState() {
    super.initState();

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
      appBar: MyAppBarWithCalc(
          widget.editMode ?? false ? 'Edit Ingredient' : 'Create Ingredient'),
      // AppBar(
      //   title: Text('Create Ingredient'),
      // ),
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
                      if (currencySnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return MyLoadingCircle(500);
                      }
                      _currencyChosen = currencySnapshot.data;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //TODO refactor med textfield...
                          CreateElementTextField(
                            title: 'my Name',
                            myValue: _name,
                            textEditingController: _nameController,
                            validate: validateString,
                            setValue: (value) => _name = value,
                            // textInputType: TextInputType.text,
                          ),

                          CreateElementTextField(
                            title: 'Kg Price / Liter Price',
                            myValue: _kgPrice,
                            textEditingController: _kgPriceController,
                            validate: validateDouble,
                            setValue: (value) => _kgPrice = value,
                            readOnly: true,
                            onTap: () => inputAmuntDialog(),
                            suffixText:
                                _measureUnit == 'Kg' || _measureUnit == 'g'
                                    ? '$_currencyChosen/Kg'
                                    : '$_currencyChosen/Liter',
                          ),

                          // TextFormField(
                          //   controller: _nameController,
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     labelText: 'Name',
                          //   ),
                          //   textCapitalization: TextCapitalization.words,
                          //   keyboardType: TextInputType.text,
                          //   validator: (value) => validateString(value),
                          //   onSaved: (value) => _name = value,
                          //   onFieldSubmitted: (value) => changeFocus(),
                          // ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // Container(
                          //   child: TextFormField(
                          //     readOnly: true,
                          //     onTap: () {
                          //       inputAmuntDialog();
                          //     },
                          //     controller: _kgPriceController,
                          //     decoration: InputDecoration(
                          //       suffixText:
                          //           _measureUnit == 'Kg' || _measureUnit == 'g'
                          //               ? '$_currencyChosen/Kg'
                          //               : '$_currencyChosen/Liter',
                          //       border: OutlineInputBorder(),
                          //       labelText: 'Kg Price / Liter Price',
                          //     ),
                          //     inputFormatters: <TextInputFormatter>[
                          //       FilteringTextInputFormatter.allow(
                          //           RegExp(r'[0-9,.]'))
                          //     ],
                          //     keyboardType: TextInputType.numberWithOptions(
                          //         decimal: true),
                          //     validator: (value) => validateDouble(value),
                          //     onSaved: (value) => _kgPrice = value,
                          //     onFieldSubmitted: (value) => changeFocus(),
                          //   ),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          MyIconButton(
                            tileIcon: Icon(Icons.save),
                            compact: true,
                            tileTitle: 'Save Ingredient',
                            myOnPressed: () => _saveIngredient(),
                          ),

                          widget.editMode ?? false
                              ? IconButton(
                                  padding: EdgeInsets.all(40),
                                  iconSize: 40,
                                  color: Colors.red,
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteIngredientDialog(context),
                                )
                              : Center(),
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
      String _newMeasureUnit =
          _measureUnit == 'Kg' || _measureUnit == 'g' ? 'Kg' : 'Liter';
      Ingredient newIngredient =
          Ingredient(newID, _name, finalKgPrice, 4294198070, _newMeasureUnit);

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
    }
  }

//Save to firestore database
  Future<bool> _saveIngredientToFile(Ingredient newIngredient) async {
    try {
      String ingredientFileContent =
          await fileManagement.readFile(ingredientJsonFile);
      List<Ingredient> allIngredientsFromFile =
          objManager.jsonToListIngredient(ingredientFileContent);

      if (widget.editMode ?? false) {
        String mealFileContent = await fileManagement.readFile(mealJsonFile);
        String menuFileContent = await fileManagement.readFile(menuJsonFile);
        List<Meal> allMealsFromFile =
            objManager.jsonToListMeal(mealFileContent);
        List<Menu> allMenusFromFile =
            objManager.jsonToListMenu(menuFileContent);

        int ingredientEditIndex = allIngredientsFromFile
            .indexWhere((element) => element.id == newIngredient.id);
        allIngredientsFromFile[ingredientEditIndex] = newIngredient;

        //Update data of ingredients in meals
        allMealsFromFile.forEach((meal) {
          int mealEditIndex = meal.ingredients
              .indexWhere((element) => element.id == newIngredient.id);
          if (mealEditIndex != -1) {
            Ingredient newIngredientWGrams = Ingredient.clone(newIngredient);
            double amountInGrams =
                meal.ingredients[mealEditIndex].amountInGrams;
            newIngredientWGrams.amountInGrams = amountInGrams;
            meal.ingredients[mealEditIndex] = newIngredientWGrams;
          }
        });
        //Update data of ingredients in menus
        allMenusFromFile.forEach((menu) {
          int menuEditIndex = menu.ingredients
              .indexWhere((element) => element.id == newIngredient.id);
          print('index: $menuEditIndex');
          if (menuEditIndex != -1) {
            Ingredient newIngredientWGrams = Ingredient.clone(newIngredient);
            double amountInGrams =
                menu.ingredients[menuEditIndex].amountInGrams;
            newIngredientWGrams.amountInGrams = amountInGrams;
            menu.ingredients[menuEditIndex] = newIngredientWGrams;
          }

          //Update data of ingredients in menu's meals
          menu.meals.forEach((meal) {
            int menuMealEditIndex = meal.ingredients
                .indexWhere((element) => element.id == newIngredient.id);
            print('index Meal: $menuMealEditIndex');

            if (menuMealEditIndex != -1) {
              Ingredient newIngredientWGramsMeal =
                  Ingredient.clone(newIngredient);
              double amountInGramsMeal =
                  meal.ingredients[menuMealEditIndex].amountInGrams;
              newIngredientWGramsMeal.amountInGrams = amountInGramsMeal;
              meal.ingredients[menuMealEditIndex] = newIngredientWGramsMeal;
            }
          });
        });
        fileManagement.writeFile(mealJsonFile, jsonEncode(allMealsFromFile));
        fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
      } else {
        allIngredientsFromFile.add(newIngredient);
      }
      fileManagement.writeFile(
          ingredientJsonFile, jsonEncode(allIngredientsFromFile));
    } catch (error) {
      print('Error saving ingredient: $error');
      return false;
    }
    return true;
  }

  //Delete ingredient menu box
  _deleteIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: 'Delete Ingredient',
          content:
              'This cannot be undone, are you sure you want to delete this ingredient?',
          cancelText: 'No',
          confirmText: 'Yes',
          myOnPressed: () => _deleteIngredient(context),
        );
        // return AlertDialog(
        //   title: Text('Delete Ingredient'),
        //   content: Text(
        //       'This cannot be undone, are you sure you want to delete this ingredient?'),
        //   actions: [
        //     TextButton(
        //       child: Text('No'),
        //       onPressed: () {
        //         Navigator.pop(context);
        //       },
        //     ),
        //     ElevatedButton(
        //       child: Text('Yes'),
        //       style: ElevatedButton.styleFrom(primary: Colors.red),
        //       onPressed: () => _deleteIngredient(context),
        //     )
        //   ],
        // );
      },
    );
  }

  _deleteIngredient(BuildContext context) async {
    String ingredientFileContent =
        await fileManagement.readFile(ingredientJsonFile);
    List<Ingredient> allIngredientsFromFile =
        objManager.jsonToListIngredient(ingredientFileContent);
    String mealFileContent = await fileManagement.readFile(mealJsonFile);
    List<Meal> allMealsFromFile = objManager.jsonToListMeal(mealFileContent);
    int ingredientFoundIndex = -1;
    if (allMealsFromFile != null) {
      for (var m in allMealsFromFile) {
        ingredientFoundIndex =
            m.ingredients.indexWhere((i) => i.id == widget.editIngredient.id);
        if (ingredientFoundIndex >= 0) {
          break;
        }
      }
    }

    String menuFileContent = await fileManagement.readFile(menuJsonFile);
    List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
    int ingredientinmenuFoundIndex = -1;
    if (allMenusFromFile != null) {
      for (var m in allMenusFromFile) {
        ingredientinmenuFoundIndex =
            m.ingredients.indexWhere((i) => i.id == widget.editIngredient.id);
        if (ingredientinmenuFoundIndex >= 0) {
          break;
        }
      }
    }

    if (ingredientFoundIndex != -1 || ingredientinmenuFoundIndex != -1) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: 'Error',
            content:
                'Could not delete ingredient, because one or more meals or menus are using it.',
            cancelText: 'Close',
            infoDialog: true,
          );
          // return AlertDialog(
          //   title: Text('Error'),
          //   content: Text(
          //       'Could not delete ingredient, because one or more meals or menus are using it.'),
          //   actions: [
          //     TextButton(
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //         },
          //         child: Text('Ok'))
          //   ],
          // );
        },
      );
    } else {
      int deleteIndex = allIngredientsFromFile
          .indexWhere((element) => element.id == widget.editIngredient.id);
      allIngredientsFromFile.removeAt(deleteIndex);

      fileManagement.writeFile(
          ingredientJsonFile, jsonEncode(allIngredientsFromFile));
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${widget.editIngredient.name} was deleted.')));
    }
  }

  void inputAmuntDialog() {
    _tempMeasureUnit = _measureUnit;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding:
                EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 5),
            content:
                StatefulBuilder(builder: (BuildContext context, setModalState) {
              return Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKeyDialog,
                child: Container(
                  // color: Colors.red,
                  height: 210,
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            suffixText: ',- $_currencyChosen',
                            labelText: 'Price for amount',
                            errorStyle: TextStyle(height: 0.5),
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,.]'))
                          ],
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => validateDouble(value),
                          onSaved: (value) => _amountPrice = value,
                          onFieldSubmitted: (value) => changeFocus(),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 70,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Amount in $_tempMeasureUnit',
                            suffixText: _tempMeasureUnit,
                            errorStyle: TextStyle(height: 0.5),
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,.]'))
                          ],
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => validateDouble(value),
                          onSaved: (value) => _amountValue = value,
                          onFieldSubmitted: (value) => changeFocus(),
                        ),
                      ),
                      MeasureUnitButtonGrid(
                          tempChosenUnit: _tempMeasureUnit,
                          dropDownValues: ["g", "ml", "Kg", "Liter"],
                          changeToValue: (value) {
                            setModalState(() {
                              changeMeasureUnitValue(value);
                            });
                          }),
                      // Container(
                      //   // color: Colors.red,
                      //   width: 200,
                      //   height: 70,
                      //   // padding: EdgeInsets.only(top: 20),
                      //   child: GridView.count(
                      //     physics: NeverScrollableScrollPhysics(),
                      //     crossAxisCount: 4,
                      //     children: <String>[
                      //       "g",
                      //       "ml",
                      //       "Kg",
                      //       "Liter",
                      //     ].map<DropdownMenuItem<String>>((String value) {
                      //       return DropdownMenuItem<String>(
                      //         value: value,
                      //         child: meassureUnitGridTile(value, setModalState),
                      //       );
                      //     }).toList(),
                      //   ),
                      // )
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

  // Widget meassureUnitGridTile(
  //     String unit, void Function(void Function()) setModalState) {
  //   return AnimatedContainer(
  //     curve: Curves.decelerate,
  //     duration: Duration(milliseconds: 200),
  //     padding: EdgeInsets.all(unit == _tempMeasureUnit ? 0 : 5),
  //     child: InkWell(
  //       onTap: () {
  //         setModalState(() {
  //           _tempMeasureUnit = unit;
  //         });
  //       },
  //       child: Card(
  //         margin: EdgeInsets.all(0),
  //         color: unit == _tempMeasureUnit ? Colors.blue : Colors.blue[100],
  //         child: Center(
  //             child: Text(
  //           unit,
  //           style: TextStyle(
  //               color: unit == _tempMeasureUnit ? Colors.white : Colors.white),
  //         )),
  //       ),
  //     ),
  //   );
  // }

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
