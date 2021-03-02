import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/FileManagement.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import 'package:profit_calculator/ObjectManager.dart';
import 'package:profit_calculator/main.dart';
import 'Model/Ingredient.dart';
import 'Model/EnvironmentConfig.dart' as config;

class CreateMeal extends StatefulWidget {
  final bool editMode;
  final Meal editMeal;
  CreateMeal({this.editMode, this.editMeal});

  @override
  _CreateMealState createState() => _CreateMealState();
}

class _CreateMealState extends State<CreateMeal> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _salePrice;
  String _profitMargin;
  bool _salePriceChosen = true;

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();

  List<Ingredient> _selectedIngredients = <Ingredient>[];
  List<Ingredient> ingredients = <Ingredient>[];

  String mealJsonFile = config.mealJsonFile;
  String ingredientJsonFile = config.ingredientJsonFile;

  //Get all ingredients from firestore
  getIngredientsFromFile() async {
    String fileContent = await fileManagement.readFile(ingredientJsonFile);
    List<Ingredient> tempIngredients = <Ingredient>[];

    tempIngredients = objManager.jsonToListIngredient(fileContent);
    ingredients = tempIngredients;
    // tempIngredients.where((element) => element.archived == false).toList();
  }

//Check if meal is being edited and insert object.
  initEditMode() {
    if (widget.editMode ?? false) {
      _name = widget.editMeal.name;
      _salePrice = widget.editMeal.salePrice.toString();
      _selectedIngredients = widget.editMeal.ingredients
          ?.map((e) => Ingredient.clone(e))
          ?.toList();
    }
  }

  @override
  void initState() {
    super.initState();
    getIngredientsFromFile();

    initEditMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.editMode ?? false
          ? MyAppBarWithCalc('Edit Meal')
          : MyAppBarWithCalc('Create Meal'),

      // appBar: AppBar(
      //     title: widget.editMode ?? false
      //         ? Text('Edit Meal')
      //         : Text('Create Meal')),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                      initialValue: _name,
                      keyboardType: TextInputType.name,
                      validator: (value) => validateString(value),
                      onSaved: (value) => _name = value,
                      onFieldSubmitted: (value) => changeFocus(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      !_salePriceChosen
                          ? Container(
                              width: 150,
                              child: Text(
                                'Sale Price in kr,-',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ))
                          : Container(
                              width: 150,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Sale Price in kr,-',
                                ),
                                initialValue: _salePrice,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
                                ],
                                keyboardType: TextInputType.phone,
                                validator: (value) => validateDouble(value),
                                onSaved: (value) => _salePrice = value,
                                onFieldSubmitted: (value) => changeFocus(),
                              ),
                            ),
                      CircleAvatar(
                        child: IconButton(
                          icon: Icon(_salePriceChosen
                              ? Icons.arrow_back
                              : Icons.arrow_forward),
                          onPressed: () {
                            setState(() {
                              _salePriceChosen = !_salePriceChosen;
                            });
                          },
                        ),
                      ),
                      _salePriceChosen
                          ? Container(
                              width: 150,
                              child: Text(
                                'Profit Margin in %',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ))
                          : Container(
                              width: 150,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Profit Margin in %',
                                ),
                                initialValue: _profitMargin,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
                                ],
                                keyboardType: TextInputType.phone,
                                validator: (value) => validateDouble(value),
                                onSaved: (value) => _profitMargin = value,
                                onFieldSubmitted: (value) => changeFocus(),
                              ),
                            ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ListView.builder(
                      itemCount: _selectedIngredients.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ingredientListTile(_selectedIngredients[index]);
                      },
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 200,
                    child: RaisedButton.icon(
                        padding: EdgeInsets.all(15),
                        icon: Icon(Icons.add),
                        label: Text('Add Ingredients'),
                        color: Colors.pink,
                        onPressed: () {
                          _showEditIngredients(ingredients);
                        }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 200,
                    child: RaisedButton.icon(
                        icon: Icon(Icons.save),
                        padding: EdgeInsets.all(15),
                        label: Text('Save Meal'),
                        onPressed: () => _saveMeal(false)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // widget.editMode ?? false
                  //     ? Container(
                  //         width: 200,
                  //         child: FlatButton.icon(
                  //             icon: Icon(Icons.copy),
                  //             padding: EdgeInsets.all(15),
                  //             label: Text('Dublicate'),
                  //             onPressed: () => _saveMeal(true)),
                  //       )
                  //     : Center(),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Show a menu to choose wich ingredients are in the meal
  _showEditIngredients(List<Ingredient> ingredients) {
    bool showArchived = false;
    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setModalState) {
            return SingleChildScrollView(
              child: Column(children: [
                AppBar(
                  title: Text('Add ingredients'),
                  backgroundColor: Colors.pink,
                  actions: [
                    IconButton(
                        icon: showArchived
                            ? Icon(Icons.archive_outlined)
                            : Icon(Icons.archive),
                        onPressed: () {
                          setModalState(() {
                            showArchived = !showArchived;
                          });
                          print(showArchived);
                        })
                  ],
                ),
                Container(
                  height: (MediaQuery.of(context).size.height - 200),
                  child: ingredients.length == 0
                      ? Center(
                          child: Text(
                              'You have no ingredients.\nCreate ingredients in the menu.\n\n\n',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              )))
                      : ListView.builder(
                          itemCount: ingredients.length,
                          itemBuilder: (BuildContext context, int index) {
                            return addIngredientListTile(ingredients[index],
                                setModalState, showArchived);
                          },
                        ),
                ),
                Container(
                  width: double.infinity,
                  height: 90,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: RaisedButton(
                    elevation: 5,
                    child: Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                )
              ]),
            );
          },
        );
      },
      context: context,
    );
  }

// Create final meal object and save it
  _saveMeal(bool dublicate) async {
    if (_formKey.currentState.validate()) {
      // if (_selectedIngredients.length == 0) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text('No ingredients added.'),
      //   ));
      //   return;
      // }
      int nullIndex = _selectedIngredients
          .indexWhere((ingredient) => ingredient.amountInGrams == null);

      if (nullIndex == -1) {
        _formKey.currentState.save();
        double _finalSalePrice;

        double _totalPrice = 0;
        _selectedIngredients.forEach((e) {
          if (e.measureUnit == 'ml' || e.measureUnit == 'g') {
            _totalPrice += (e.amountInGrams) * e.kgPrice;
          } else
            _totalPrice += (e.amountInGrams / 1000) * e.kgPrice;
        });

        if (_salePriceChosen)
          _finalSalePrice = double.parse(_salePrice);
        else
          _finalSalePrice =
              _totalPrice / (1 - double.parse(_profitMargin) / 100);

        _finalSalePrice = (_finalSalePrice * 100).roundToDouble() / 100;

        int newID;
        if (!dublicate) {
          if (widget.editMode ?? false)
            newID = widget.editMeal.id;
          else
            newID = DateTime.now().millisecondsSinceEpoch;
        } else
          newID = DateTime.now().millisecondsSinceEpoch;

        Meal newMeal =
            Meal(newID, _name, _finalSalePrice, _selectedIngredients);
        // print('${newMeal.id}, ${newMeal.ingredients}, ${newMeal.name}, ${newMeal.salePrice},');

        bool saveSucess = false;

        saveSucess = await _saveMealToFile(newMeal);

        if (saveSucess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_name + ' has been saved.'),
          ));
          // Navigator.of(context).pop('newMealsss');
          if (!dublicate) {
            if (widget.editMode ?? false) {
              Navigator.of(context).pop(newMeal);
              // Navigator.of(context).pushReplacement(MaterialPageRoute(
              //     builder: (context) => SingleMeal(newMeal.name, newMeal)));
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),
                  (route) => false);
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Something went wrong, please try again.'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill out all ingredients.'),
        ));
      }
    }
  }

// Save object to json File
  Future<bool> _saveMealToFile(Meal newMeal) async {
    try {
      String fileContent = await fileManagement.readFile(mealJsonFile);
      List<Meal> allMealsFromFile = objManager.jsonToListMeal(fileContent);
      if (widget.editMode ?? false) {
        int editIndex =
            allMealsFromFile.indexWhere((element) => element.id == newMeal.id);
        allMealsFromFile[editIndex] = newMeal;
      } else {
        allMealsFromFile.add(newMeal);
      }
      fileManagement.writeFile(mealJsonFile, jsonEncode(allMealsFromFile));
    } catch (error) {
      print('Error saving meal: $error');
      return false;
    }
    return true;
  }

// Each ingredient tile of the selected ingredients.
  Widget ingredientListTile(Ingredient ingredient) {
    TextEditingController tec =
        TextEditingController(text: ingredient.amountInGrams?.toString() ?? '');
    return Card(
      child: ListTile(
          title: Row(children: [
            CircleAvatar(
              backgroundColor: Color(ingredient.color),
              radius: 10,
            ),
            Text('   ' + ingredient.name),
          ]),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                padding: EdgeInsets.all(5),
                width: 90,
                child: TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  keyboardType: TextInputType.phone,
                  maxLength: 4,
                  maxLengthEnforced: true,
                  controller: tec,
                  decoration: InputDecoration(
                      // hintText: ingredient.measureUnit == 'Kg' ? 'Grams  ' : 'Mililiter',
                      border: OutlineInputBorder(),
                      counterText: ''),
                  onChanged: (value) => takeNumber(value, ingredient.id),
                )),
            Text(ingredient.measureUnit == 'Kg' ? 'g  ' : 'ml')
          ])),
    );
  }

  //Give ingredients an amountInGrams value
  void takeNumber(String text, int itemId) {
    try {
      int ingredientIndex = _selectedIngredients
          .indexWhere((ingredient) => ingredient.id == itemId);
      if (text != '') {
        double number = double.parse(text);
        _selectedIngredients[ingredientIndex].amountInGrams = number;
      } else {
        _selectedIngredients[ingredientIndex].amountInGrams = null;
      }
    } catch (error) {
      print('takeNumber Error: ' + error.toString());
    }
  }

// Each ingredient widget in the menu to choose ingredients
  Widget addIngredientListTile(
      Ingredient ingredient, Function setModalState, bool showArchived) {
    if (!showArchived) {
      if (ingredient.archived) return Center();
    } else {
      if (!ingredient.archived) return Center();
    }
    return Card(
      child: CheckboxListTile(
        // tileColor: ingredient.color,
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Color(ingredient.color),
            radius: 10,
          ),
          Text('   ' + ingredient.name),
        ]),
        value:
            _selectedIngredients.indexWhere((e) => e.id == ingredient.id) != -1,
        onChanged: (bool selected) {
          _onIngredientSelected(selected, ingredient, setModalState);
        },
      ),
    );
  }

// Add or remove the ingredient pressed to a new list of selected ingredients
  void _onIngredientSelected(
      bool selected, Ingredient ingredient, Function setModalState) {
    if (selected == true) {
      setModalState(() {
        _selectedIngredients.add(ingredient);
      });
    } else {
      setModalState(() {
        _selectedIngredients.removeWhere((e) => e.id == ingredient.id);
      });
    }
  }

// change the focus from fx a textfield to remove keyboard when background is pressed
  void changeFocus() {
    FocusScope.of(context).nextFocus();
  }

//check if string is empty
  String validateString(String value) {
    return value.isEmpty ? 'Required' : null;
  }

// Check if the number value is valid
  String validateDouble(String value) {
    try {
      double.parse(value);
      return null;
    } catch (error) {
      return "Invalid number.";
    }
  }
}
