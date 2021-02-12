import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:profit_calculator/FileManagement.dart';
import 'Model/Ingredient.dart';
import 'main.dart';

class CreateIngredient extends StatefulWidget {
  final bool editMode;
  final Ingredient editIngredient;

  CreateIngredient({this.editMode, this.editIngredient});

  @override
  _CreateIngredientState createState() => _CreateIngredientState();
}

class _CreateIngredientState extends State<CreateIngredient> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _kgPrice = '';
  String _measureUnit = 'Kg';
  Color currentColor = Colors.red;

  List<Ingredient> ingredientsList = List<Ingredient>();

  final FileManagement fileManagement = FileManagement();

  @override
  void initState() {
    super.initState();

    initEditMode();
  }

//Check if ingredient is being edited and then insert object
  initEditMode() {
    if (widget.editMode ?? false) {
      currentColor = Color(widget.editIngredient.color);
      _name = widget.editIngredient.name;
      _kgPrice = widget.editIngredient.kgPrice.toString();
      _measureUnit = widget.editIngredient.measureUnit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ingredient'),
      ),
      body: SingleChildScrollView(
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
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    initialValue: _name,
                    keyboardType: TextInputType.name,
                    validator: (value) => validateString(value),
                    onSaved: (value) => _name = value,
                    onFieldSubmitted: (value) => changeFocus(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 180,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Price per Kg/Liter',
                          ),
                          initialValue: _kgPrice,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ],
                          keyboardType: TextInputType.phone,
                          validator: (value) => validateDouble(value),
                          onSaved: (value) => _kgPrice = value,
                          onFieldSubmitted: (value) => changeFocus(),
                        ),
                      ),
                      Container(
                          width: 70,
                          // height: 70,
                          padding: EdgeInsets.only(top: 20),
                          child: DropdownButton(
                              value: _measureUnit,
                              // style: TextStyle(color: Colors.white),
                              // iconEnabledColor: Colors.white,
                              // dropdownColor: Colors.blue,
                              items: <String>[
                                "Kg",
                                "Liter",
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _measureUnit = newValue;
                                });
                              }))
                    ],
                  ),
                  Text(
                    '\nPick a color identifier',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 0, right: 50, left: 50),
                    height: 290,
                    width: 320,
                    child: BlockPicker(
                      pickerColor: currentColor,
                      onColorChanged: changeColor,
                    ),
                  ),
                  Container(
                      width: 200,
                      child: RaisedButton.icon(
                          icon: Icon(Icons.save),
                          padding: EdgeInsets.all(15),
                          label: Text('Save Ingredient'),
                          onPressed: () => _saveIngredient())),
                  SizedBox(
                    height: 20,
                  ),
                  widget.editMode ?? false
                      ? IconButton(
                          padding: EdgeInsets.all(20),
                          iconSize: 40,
                          color: Colors.red,
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteIngredientDialog(context),
                        )
                      : Center(),
                ],
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

      double finalKgPrice = double.parse(_kgPrice);
//Create new id or use edit ingredient id
      int newID;
      if (widget.editMode ?? false)
        newID = widget.editIngredient.id;
      else
        newID = DateTime.now().millisecondsSinceEpoch;

//Create object
      Ingredient newIngredient = Ingredient(
          newID, _name, finalKgPrice, currentColor.value, _measureUnit);

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
      String fileContent = await fileManagement.readFile('IngredientListJson');
      Iterable tempIngredientIterable = json.decode(fileContent);
      // print('all ingredients ${json.decode(ingredientSnapshot.data)}');
      List<Ingredient> allIngredients =
          tempIngredientIterable?.map((e) => Ingredient.fromJson(e))?.toList();
      if (widget.editMode ?? false) {
        int editIndex = allIngredients
            .indexWhere((element) => element.id == newIngredient.id);
        allIngredients[editIndex] = newIngredient;
      } else {
        allIngredients.add(newIngredient);
      }
      fileManagement.writeFile(
          'IngredientListJson', jsonEncode(allIngredients));
    } catch (error) {
      print('Error saving ingredient: $error');
      return false;
    }
    return true;
  }

//Show delete menu box
  _deleteIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Archive'),
          content: Text(
              'Are you sure you want to archive ${widget.editIngredient.name}?'),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text('Archive'),
              color: Colors.red,
              onPressed: () => _archiveIngredient(context),
            )
          ],
        );
      },
    );
  }

//Archive ingredient and show error or succes messages
  _archiveIngredient(BuildContext context) async {
    bool archiveSuccess = false;

    archiveSuccess = await _archiveIngredientFromFile(widget.editIngredient);

    if (archiveSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
          (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.editIngredient.name} was archived.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong, please try again.'),
      ));
    }
  }

//Delete ingredient from firestore database
  Future<bool> _archiveIngredientFromFile(Ingredient editIngredient) async {
    try {
      String fileContent = await fileManagement.readFile('IngredientListJson');
      Iterable tempIngredientIterable = json.decode(fileContent);
      // print('all ingredients ${json.decode(ingredientSnapshot.data)}');
      List<Ingredient> allIngredients =
          tempIngredientIterable?.map((e) => Ingredient.fromJson(e))?.toList();
      int archiveIndex = allIngredients
          .indexWhere((element) => element.id == editIngredient.id);
      allIngredients[archiveIndex].archived = true;
      fileManagement.writeFile(
          'IngredientListJson', jsonEncode(allIngredients));
    } catch (error) {
      print('Error saving ingredient: $error');
      return false;
    }
    return true;
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
      double.parse(value);
      return null;
    } catch (error) {
      return "Invalid number. Use '.' as komma.";
    }
  }

//change color in the color selector
  void changeColor(Color color) => setState(() => currentColor = color);
}
