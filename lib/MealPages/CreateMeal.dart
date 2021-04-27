import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/main.dart';
import '../Model/Ingredient.dart';
import '../Model/EnvironmentConfig.dart' as config;

class CreateMeal extends StatefulWidget {
  final bool editMode;
  final Meal editMeal;
  final Menu editMenu;
  final bool isMeals;
  CreateMeal({this.editMode, this.editMeal, this.editMenu, this.isMeals});

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
  List<Meal> _selectedMeals = <Meal>[];
  List<Ingredient> ingredients = <Ingredient>[];
  List<Meal> meals = <Meal>[];

  String ingredientJsonFile = config.ingredientJsonFile;
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;

  //Get all ingredients from firestore
  getIngredientsFromFile() async {
    String fileContent = await fileManagement.readFile(ingredientJsonFile);
    List<Ingredient> tempIngredients = <Ingredient>[];

    tempIngredients = objManager.jsonToListIngredient(fileContent);
    ingredients = tempIngredients;
    // tempIngredients.where((element) => element.archived == false).toList();
  }

  getMealsFromFile() async {
    String fileContent = await fileManagement.readFile(mealJsonFile);
    List<Meal> tempMeals = <Meal>[];

    tempMeals = objManager.jsonToListMeal(fileContent);
    meals = tempMeals;
    // tempIngredients.where((element) => element.archived == false).toList();
  }

//Check if meal is being edited and insert object.
  initEditMealMode() {
    String tempSale;
    _name = widget.editMeal.name;
    tempSale = widget.editMeal.salePrice.toString();
    _salePrice = tempSale.replaceAll('.', ',');
    _selectedIngredients =
        widget.editMeal.ingredients?.map((e) => Ingredient.clone(e))?.toList();
  }

  initEditMenuMode() {
    String tempSale;
    _name = widget.editMenu.name;
    tempSale = widget.editMenu.salePrice.toString();
    _salePrice = tempSale.replaceAll('.', ',');
    _selectedIngredients =
        widget.editMenu.ingredients?.map((e) => Ingredient.clone(e))?.toList();
    _selectedMeals = widget.editMenu.meals?.map((e) => Meal.clone(e))?.toList();
  }

  @override
  void initState() {
    super.initState();
    getIngredientsFromFile();
    getMealsFromFile();

    if (widget.editMode ?? false) {
      if (widget.isMeals ?? false) {
        initEditMealMode();
      } else {
        initEditMenuMode();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc(widget.isMeals ? 'Create Meal' : 'Create Menu'),
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
                                'Sale Price',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ))
                          : Container(
                              width: 150,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Sale Price',
                                ),
                                initialValue: _salePrice,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]'))
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
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
                                'Profit Margin %',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ))
                          : Container(
                              width: 150,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Profit Margin %',
                                ),
                                initialValue: _profitMargin,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]'))
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (value) => validateDouble(value),
                                onSaved: (value) => _profitMargin = value,
                                onFieldSubmitted: (value) => changeFocus(),
                              ),
                            ),
                    ],
                  ),
                  Divider(thickness: 1),
                  Text(
                    _selectedIngredients.length == 0
                        ? 'No ingredients added.'
                        : 'Ingredients:',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w300),
                  ),
                  Container(
                    // color: Colors.red,
                    padding: EdgeInsets.all(10),
                    child: ListView.builder(
                      padding: EdgeInsets.all(0),
                      itemCount: _selectedIngredients.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ingredientListTile(_selectedIngredients[index]);
                      },
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ),
                  Divider(thickness: 1),
                  !widget.isMeals
                      ? Text(
                          _selectedMeals.length == 0
                              ? 'No meals added.'
                              : 'Meals:',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300),
                        )
                      : Center(),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ListView.builder(
                      padding: EdgeInsets.all(0),
                      itemCount: _selectedMeals.length,
                      itemBuilder: (BuildContext context, int index) {
                        return mealListTile(_selectedMeals[index]);
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
                          _showEditIngredients(
                              eIngredients: ingredients, eIsIngredients: true);
                        }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  !widget.isMeals
                      ? Container(
                          width: 200,
                          child: RaisedButton.icon(
                              padding: EdgeInsets.all(15),
                              icon: Icon(Icons.add),
                              label: Text('Add Meals'),
                              color: Colors.pink,
                              onPressed: () {
                                _showEditIngredients(
                                    eMeals: meals, eIsIngredients: false);
                              }),
                        )
                      : Center(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 200,
                    child: RaisedButton.icon(
                        icon: Icon(Icons.save),
                        padding: EdgeInsets.all(15),
                        label: Text(widget.isMeals ? 'Save Meal' : 'Save Menu'),
                        onPressed: () => _saveMeal(false)),
                  ),
                  Container(
                    width: 200,
                    child: RaisedButton.icon(
                        icon: Icon(Icons.save),
                        padding: EdgeInsets.all(15),
                        label: Text('delete Menu'),
                        onPressed: () async {
                          try {
                            fileManagement.writeFile(menuJsonFile, '');
                          } catch (error) {
                            print('Error saving meal: $error');
                            return false;
                          }
                          return true;
                        }),
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
                  SizedBox(height: 40),
                  SizedBox(height: 400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Show a menu to choose wich ingredients are in the meal
  _showEditIngredients(
      {List<Ingredient> eIngredients, List<Meal> eMeals, bool eIsIngredients}) {
    String ingredientOrMeal = eIsIngredients ? 'ingredients' : 'meals';
    bool listIsEmpty = false;
    if (eIsIngredients) {
      if (eIngredients.length == 0) {
        listIsEmpty = true;
      }
    } else {
      if (eMeals.length == 0) {
        listIsEmpty = true;
      }
    }
    //bool showArchived = false;
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
                  title: Text('Add $ingredientOrMeal'),
                  backgroundColor: Colors.pink,
                ),
                Container(
                  height: (MediaQuery.of(context).size.height - 200),
                  child: listIsEmpty
                      ? Center(
                          child: Text(
                              'You have no $ingredientOrMeal.\nCreate $ingredientOrMeal in the menu.\n\n\n',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              )))
                      : ListView.builder(
                          itemCount: eIsIngredients
                              ? eIngredients.length
                              : eMeals.length,
                          itemBuilder: (BuildContext context, int index) {
                            return eIsIngredients
                                ? addIngredientListTile(
                                    eIngredients[index], setModalState)
                                : addMealListTile(eMeals[index], setModalState);
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

        if (_salePriceChosen) {
          String tempSale = _salePrice.replaceAll(',', '.');
          _finalSalePrice = double.parse(tempSale);
        } else {
          String tempProfit = _profitMargin.replaceAll(',', '.');

          _finalSalePrice = _totalPrice / (1 - double.parse(tempProfit) / 100);
        }

        _finalSalePrice = (_finalSalePrice * 100).roundToDouble() / 100;

        int newID;
        if (!dublicate) {
          if (widget.editMode ?? false) {
            if (widget.isMeals) {
              newID = widget.editMeal.id;
            } else {
              newID = widget.editMenu.id;
            }
          } else
            newID = DateTime.now().millisecondsSinceEpoch;
        } else
          newID = DateTime.now().millisecondsSinceEpoch;

        Meal newMeal;
        Menu newMenu;
        if (widget.isMeals) {
          newMeal = Meal(newID, _name, _finalSalePrice, _selectedIngredients);
        } else {
          newMenu = Menu(newID, _name, _finalSalePrice, _selectedIngredients,
              _selectedMeals);
        }

        // print('${newMeal.id}, ${newMeal.ingredients}, ${newMeal.name}, ${newMeal.salePrice},');

        bool saveSucess = false;

        if (widget.isMeals) {
          saveSucess = await _saveMealToFile(newMeal);
        } else {
          saveSucess = await _saveMenuToFile(newMenu);
        }

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

  Future<bool> _saveMenuToFile(Menu newMenu) async {
    try {
      String fileContent = await fileManagement.readFile(menuJsonFile);
      List<Menu> allMenusFromFile = objManager.jsonToListMenu(fileContent);
      if (widget.editMode ?? false) {
        int editIndex =
            allMenusFromFile.indexWhere((element) => element.id == newMenu.id);
        allMenusFromFile[editIndex] = newMenu;
      } else {
        allMenusFromFile.add(newMenu);
      }
      fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
    } catch (error) {
      print('Error saving menu: $error');
      return false;
    }
    return true;
  }

// Each ingredient tile of the selected ingredients.
  Widget ingredientListTile(Ingredient ltIngredient) {
    TextEditingController tec = TextEditingController(
        text: ltIngredient.amountInGrams?.toString() ?? '');
    return Card(
      child: ListTile(
          title: Text(ltIngredient.name),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                padding: EdgeInsets.all(5),
                width: 90,
                child: TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  maxLengthEnforced: true,
                  controller: tec,
                  decoration: InputDecoration(
                      // hintText: ingredient.measureUnit == 'Kg' ? 'Grams  ' : 'Mililiter',
                      border: OutlineInputBorder(),
                      counterText: ''),
                  onChanged: (value) => takeNumber(value, ltIngredient.id),
                )),
            Text(ltIngredient.measureUnit == 'Kg' ? 'g  ' : 'ml')
          ])),
    );
  }

  Widget mealListTile(Meal ltMeal) {
    return Card(
      child: ListTile(
          title: Text(ltMeal.name),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (ltMeal.amount > 1) {
                    setState(() {
                      ltMeal.amount--;
                    });
                  }
                }),
            Text('${ltMeal.amount}'),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    ltMeal.amount++;
                  });
                }),
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
  Widget addIngredientListTile(Ingredient aIngredient, Function setModalState) {
    return Card(
      child: CheckboxListTile(
        title: Text(aIngredient.name),
        value: _selectedIngredients.indexWhere((e) => e.id == aIngredient.id) !=
            -1,
        onChanged: (bool selected) {
          _onIngredientSelected(selected, aIngredient, setModalState);
        },
      ),
    );
  }

  Widget addMealListTile(Meal aMeal, Function setModalState) {
    return Card(
      child: CheckboxListTile(
        title: Text(aMeal.name),
        value: _selectedMeals.indexWhere((e) => e.id == aMeal.id) != -1,
        onChanged: (bool selected) {
          _onMealSelected(selected, aMeal, setModalState);
        },
      ),
    );
  }

// Add or remove the ingredient pressed to a new list of selected ingredients
  void _onIngredientSelected(
      bool iSelected, Ingredient sIngredient, Function setModalState) {
    if (iSelected == true) {
      setModalState(() {
        _selectedIngredients.add(sIngredient);
      });
    } else {
      setModalState(() {
        _selectedIngredients.removeWhere((e) => e.id == sIngredient.id);
      });
    }
  }

  void _onMealSelected(bool mSelected, Meal sMeal, Function setModalState) {
    if (mSelected == true) {
      setModalState(() {
        sMeal.amount = 1;
        _selectedMeals.add(sMeal);
      });
    } else {
      setModalState(() {
        _selectedMeals.removeWhere((e) => e.id == sMeal.id);
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
      value = value.replaceAll(',', '.');
      double.parse(value);
      return null;
    } catch (error) {
      return "Invalid number.";
    }
  }
}
