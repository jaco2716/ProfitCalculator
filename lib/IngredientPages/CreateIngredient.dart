import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Model/EnvironmentConfig.dart' as config;
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
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
  String _amountValue = '';
  String _amountPrice = '';
  Color currentColor = Colors.red;

  String ingredientJsonFile = config.ingredientJsonFile;
  String mealJsonFile = config.mealJsonFile;
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
      currentColor = Color(widget.editIngredient.color);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                      // initialValue: widget.editMode ?? false ? _name : null,
                      keyboardType: TextInputType.name,
                      validator: (value) => validateString(value),
                      onSaved: (value) => _name = value,
                      onFieldSubmitted: (value) => changeFocus(),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FutureBuilder(
                      future: _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK'),
                      initialData: '',
                      builder: (context, currencySnapshot) {
                        return Container(
                          // width: MediaQuery.of(context).size.width - 110,
                          child: TextFormField(
                            readOnly: true,
                            onTap: () {
                              inputAmuntDialog();
                            },
                            controller: _kgPriceController,
                            decoration: InputDecoration(
                              suffixText:
                                  _measureUnit == 'Kg' || _measureUnit == 'g'
                                      ? '${currencySnapshot.data}/Kg'
                                      : '${currencySnapshot.data}/Liter',
                              border: OutlineInputBorder(),
                              labelText: 'Kg Price / Liter Price',
                            ),
                            // initialValue:
                            //     widget.editMode ?? false ? _kgPrice : null,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) => validateDouble(value),
                            onSaved: (value) => _kgPrice = value,
                            onFieldSubmitted: (value) => changeFocus(),
                          ),
                        );
                      }
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        width: 200,
                        child: RaisedButton.icon(
                            icon: Icon(Icons.save),
                            padding: EdgeInsets.all(15),
                            label: Text('Save Ingredient'),
                            onPressed: () => _saveIngredient())),
                    SizedBox(
                      height: 10,
                    ),
                    // TODO delete color picker..
                    // Text(
                    //   '\nPick a color as your category',
                    //   style: TextStyle(
                    //       fontSize: 15,
                    //       // fontWeight: FontWeight.w300,
                    //       fontStyle: FontStyle.italic),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 40, vertical: 20),
                    //   child: Container(
                    //     // color: Colors.blue[100],
                    //     padding: EdgeInsets.only(top: 0, right: 20, left: 20),
                    //     height: 150,
                    //     width: 320,
                    //     child: BlockPicker(
                    //       availableColors: [
                    //         Colors.red,
                    //         Colors.orange,
                    //         Colors.yellow,
                    //         Colors.purple,
                    //         Colors.blue,
                    //         Colors.cyan,
                    //         Colors.green,
                    //         Colors.lime,
                    //         Colors.grey[300],
                    //         Colors.grey,
                    //         Colors.black,
                    //         Colors.brown,
                    //       ],
                    //       pickerColor: currentColor,
                    //       onColorChanged: changeColor,
                    //     ),
                    //   ),
                    // ),
                    // widget.editMode ?? false
                    //     ? !widget.editIngredient.archived
                    //         ? IconButton(
                    //             padding: EdgeInsets.all(20),
                    //             iconSize: 40,
                    //             color: Colors.red,
                    //             icon: Icon(Icons.archive),
                    //             onPressed: () =>
                    //                 _archiveIngredientDialog(context, false),
                    //           )
                    //         : IconButton(
                    //             padding: EdgeInsets.all(20),
                    //             iconSize: 40,
                    //             color: Colors.green,
                    //             icon: Icon(Icons.archive),
                    //             onPressed: () =>
                    //                 _archiveIngredientDialog(context, true),
                    //           )
                    //     : Center(),

                    widget.editMode ?? false
                        ? IconButton(
                            padding: EdgeInsets.all(40),
                            iconSize: 40,
                            color: Colors.red,
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteIngredientDialog(context),
                          )
                        : Center(),
                    SizedBox(
                      height: 400,
                    ),
                  ],
                ),
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
      String _newMeasureUnit = _measureUnit == 'Kg'|| _measureUnit == 'g' ? 'Kg' : 'Liter';
      Ingredient newIngredient = Ingredient(
          newID, _name, finalKgPrice, currentColor.value, _newMeasureUnit);

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
      String fileContent = await fileManagement.readFile(ingredientJsonFile);
      List<Ingredient> allIngredientsFromFile =
          objManager.jsonToListIngredient(fileContent);

      if (widget.editMode ?? false) {
        int editIndex = allIngredientsFromFile
            .indexWhere((element) => element.id == newIngredient.id);
        allIngredientsFromFile[editIndex] = newIngredient;
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
        return AlertDialog(
          title: Text('Delete Ingredient'),
          content: Text(
              'This cannot be undone, are you sure you want to delete this ingredient?'),
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
              onPressed: () => _deleteIngredient(context),
            )
          ],
        );
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

    if (ingredientFoundIndex != -1) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Could not delete ingredient, because one or more meals are using it.'),
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

//Show archive menu box
  // _archiveIngredientDialog(BuildContext context, bool alreadyArchived) {
  //   String alertContent;
  //   String actionText;
  //   alreadyArchived
  //       ? alertContent =
  //           'Are you sure you want to unarchive ${widget.editIngredient.name}?\n\nYou can allways reverse this action.'
  //       : alertContent =
  //           'Are you sure you want to archive ${widget.editIngredient.name}?\n\nYou can allways reverse this action.';
  //   alreadyArchived ? actionText = 'Unarchive' : actionText = 'Archive';

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text(actionText),
  //         content: Text(alertContent),
  //         actions: [
  //           FlatButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //           ),
  //           RaisedButton(
  //             child: Text(actionText),
  //             color: alreadyArchived ? Colors.green : Colors.red,
  //             onPressed: () => _archiveIngredient(context, alreadyArchived),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

//Archive ingredient and show error or succes messages
  // _archiveIngredient(BuildContext context, bool alreadyArchived) async {
  //   bool archiveSuccess = false;
  //   String archiveText;
  //   alreadyArchived ? archiveText = 'unarchived' : archiveText = 'archived';

  //   archiveSuccess = await _archiveIngredientFromFile(
  //       widget.editIngredient, alreadyArchived);

  //   if (archiveSuccess) {
  //     Navigator.of(context).pop();
  //     Navigator.of(context).pop();
  //     // Navigator.of(context).pushReplacement(MaterialPageRoute(
  //     //   builder: (context) => IngredientList(),
  //     // ));

  //     // Navigator.of(context).pushAndRemoveUntil(
  //     //     MaterialPageRoute(
  //     //       builder: (context) => IngredientList(),
  //     //     ),
  //     //     (route) => false);
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('${widget.editIngredient.name} was $archiveText.'),
  //     ));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Something went wrong, please try again.'),
  //     ));
  //   }
  // }

//Archive ingredient from firestore database
  // Future<bool> _archiveIngredientFromFile(
  //     Ingredient editIngredient, bool alreadyArchived) async {
  //   try {
  //     String fileContent = await fileManagement.readFile(ingredientJsonFile);
  //     List<Ingredient> allIngredients =
  //         objManager.jsonToListIngredient(fileContent);
  //     int archiveIndex = allIngredients
  //         .indexWhere((element) => element.id == editIngredient.id);
  //     alreadyArchived
  //         ? allIngredients[archiveIndex].archived = false
  //         : allIngredients[archiveIndex].archived = true;
  //     fileManagement.writeFile(ingredientJsonFile, jsonEncode(allIngredients));
  //   } catch (error) {
  //     print('Error archiving ingredient: $error');
  //     return false;
  //   }
  //   return true;
  // }

  void inputAmuntDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content:
                StatefulBuilder(builder: (BuildContext context, setModalState) {
              return Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKeyDialog,
                child: Container(
                  height: 250,
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),

                            labelText: 'Price for amount',
                            errorStyle: TextStyle(height: 0.5),
                            // counterStyle: TextStyle(height: -0.5),
                            // counterText: ' ',
                            // errorText: '',
                          ),
                          // initialValue: _kgPrice,
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
                            labelText: 'Amount in $_measureUnit',
                            errorStyle: TextStyle(height: 0.5),
                            // counterStyle: TextStyle(height: 1),
                            // counterText: ' ',
                          ),
                          // initialValue: _kgPrice,
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
                      SizedBox(
                        height: 20,
                      ),
                      // Text(''),
                      Container(
                        // color: Colors.red,
                        width: 200,
                        height: 70,
                        // padding: EdgeInsets.only(top: 20),
                        child: GridView.count(
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          children: <String>[
                            "g",
                            "ml",
                            "Kg",
                            "Liter",
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: meassureUnitGridTile(value, setModalState),
                            );
                          }).toList(),
                        ),
                        // child: DropdownButton(
                        //   value: _measureUnit,
                        //   // style: TextStyle(color: Colors.white),
                        //   // iconEnabledColor: Colors.white,
                        //   // dropdownColor: Colors.blue,
                        //   items: <String>[
                        //     "g",
                        //     "ml",
                        //     "Kg",
                        //     "Liter",
                        //   ].map<DropdownMenuItem<String>>((String value) {
                        //     return DropdownMenuItem<String>(
                        //       value: value,
                        //       child: Text(value),
                        //     );
                        //   }).toList(),
                        //   onChanged: (newValue) {
                        //     setModalState(() {
                        //       _measureUnit = newValue;
                        //     });
                        //   },
                        // ),
                      )
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
                  onPressed: () {
                    print(_formKeyDialog.currentState.validate());
                    if (_formKeyDialog.currentState.validate()) {
                      _formKeyDialog.currentState.save();

                      String tempAmountValue =
                          _amountValue.replaceAll(',', '.');
                      print(tempAmountValue);
                      String tempAmountPrice =
                          _amountPrice.replaceAll(',', '.');
                      double newAmountValue = double.parse(tempAmountValue);
                      double newAmountPrice = double.parse(tempAmountPrice);
                      double _newkgPrice = newAmountPrice / newAmountValue;
                      if (_measureUnit == 'g' || _measureUnit == 'ml') {
                        _newkgPrice *= 1000;
                      }
                      _newkgPrice = (_newkgPrice * 100).roundToDouble() / 100;
                      _kgPrice = _newkgPrice.toString().replaceAll('.', ',');
                      _kgPriceController.text = _kgPrice;
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Done'))
            ],
          );
        }).then((value) {
      setState(() {});
    });
  }

  Widget meassureUnitGridTile(
      String unit, void Function(void Function()) setModalState) {
    return AnimatedContainer(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(unit == _measureUnit ? 0 : 5),
      child: InkWell(
        onTap: () {
          setModalState(() {
            _measureUnit = unit;
          });
        },
        child: Card(
          margin: EdgeInsets.all(0),
          color: unit == _measureUnit ? Colors.blue : Colors.blue[100],
          child: Center(
              child: Text(
            unit,
            style: TextStyle(
                color: unit == _measureUnit ? Colors.white : Colors.white),
          )),
        ),
      ),
    );
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

//change color in the color selector
  //void changeColor(Color color) => setState(() => currentColor = color);
}
