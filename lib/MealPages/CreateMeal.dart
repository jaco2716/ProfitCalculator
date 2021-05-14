import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MealPages/SingleMeal.dart';
import 'package:profit_calculator/Model/Extra.dart';
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
  String _minutesToMake;
  String _profitMargin;
  bool _salePriceChosen = true;

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();

  List<Ingredient> _selectedIngredients = <Ingredient>[];
  List<Meal> _selectedMeals = <Meal>[];
  List<Extra> _selectedExtras = <Extra>[];
  List<Ingredient> ingredients = <Ingredient>[];
  List<Meal> meals = <Meal>[];
  List<Extra> extras = <Extra>[];

  String ingredientJsonFile = config.ingredientJsonFile;
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;
  String extraJsonFile = config.extraJsonFile;
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  //Get all ingredients from firestore
  getIngredientsFromFile() async {
    String fileContent = await fileManagement.readFile(ingredientJsonFile);
    List<Ingredient> tempIngredients = <Ingredient>[];

    tempIngredients = objManager.jsonToListIngredient(fileContent);
    ingredients = tempIngredients;
    // tempIngredients.where((element) => element.archived == false).toList();
  }

  getMealsFromFile() async {
    String mealFileContent = await fileManagement.readFile(mealJsonFile);
    String extraFileContent = await fileManagement.readFile(extraJsonFile);
    // List<Meal> tempMeals = <Meal>[];

    meals = objManager.jsonToListMeal(mealFileContent);
    extras = objManager.jsonToListExtra(extraFileContent);
  }

//Check if meal is being edited and insert object.
  initEditMealMode() {
    String tempSale;
    _name = widget.editMeal.name;
    _minutesToMake = widget.editMeal.minutesToMake.toString();
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
    _selectedExtras =
        widget.editMenu.extras?.map((e) => Extra.clone(e))?.toList();
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                        ),
                        initialValue: _name,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.text,
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
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                child: Text(
                                  'Sale Price',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ))
                            : Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
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
                              // print(_minutesToMake);
                              setState(() {
                                _salePriceChosen = !_salePriceChosen;
                              });
                            },
                          ),
                        ),
                        _salePriceChosen
                            ? Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                child: Text(
                                  'Profit %',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ))
                            : Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Profit %',
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
                    widget.isMeals
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Minutes to make meal',
                              ),
                              initialValue: _minutesToMake,
                              keyboardType: TextInputType.number,
                              validator: (value) => validateInt(value),
                              onSaved: (value) => _minutesToMake = value,
                              onFieldSubmitted: (value) => changeFocus(),
                            ),
                          )
                        : Center(),
                    Divider(thickness: 1),
                    itemListTitle('Ingredients:', 'No ingredients added.',
                        _selectedIngredients.length),
                    Container(
                      // color: Colors.red,
                      padding: EdgeInsets.all(10),
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: _selectedIngredients.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ingredientListTile(
                              _selectedIngredients[index], setState);
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
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
                                eIngredients: ingredients, type: 0);
                          }),
                    ),
                    !widget.isMeals
                        ? Divider(thickness: 1) : Center(),
                    !widget.isMeals
                        ? itemListTitle(
                            'Meals:', 'No meals added.', _selectedMeals.length)
                        : Center(),
                    !widget.isMeals? Container(
                      padding: EdgeInsets.all(10),
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: _selectedMeals.length,
                        itemBuilder: (BuildContext context, int index) {
                          return mealListTile(_selectedMeals[index], setState);
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ):Center(),

                    // SizedBox(
                    //   height: 20,
                    // ),
                    // Container(
                    //   width: 200,
                    //   child: RaisedButton.icon(
                    //       padding: EdgeInsets.all(15),
                    //       icon: Icon(Icons.add),
                    //       label: Text('Add Ingredients'),
                    //       color: Colors.pink,
                    //       onPressed: () {
                    //         _showEditIngredients(
                    //             eIngredients: ingredients, eIsIngredients: true);
                    //       }),
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    !widget.isMeals
                        ? Container(
                            // padding: EdgeInsets.only(bottom: 20),
                            width: 200,
                            child: RaisedButton.icon(
                                padding: EdgeInsets.all(15),
                                icon: Icon(Icons.add),
                                label: Text('Add Meals'),
                                color: Colors.pink,
                                onPressed: () {
                                  _showEditIngredients(eMeals: meals, type: 1);
                                }),
                          )
                        : Center(),
                    !widget.isMeals
                        ? Divider(thickness: 1) : Center(),
                    !widget.isMeals
                        ? itemListTitle('Extras:', 'No extras added.',
                            _selectedExtras.length)
                        : Center(),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: _selectedExtras.length,
                        itemBuilder: (BuildContext context, int index) {
                          return extraListTile(
                              _selectedExtras[index], setState);
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                    !widget.isMeals
                        ? Container(
                            padding: EdgeInsets.only(bottom: 20),
                            width: 200,
                            child: RaisedButton.icon(
                                padding: EdgeInsets.all(15),
                                icon: Icon(Icons.add),
                                label: Text('Add Extras'),
                                color: Colors.pink,
                                onPressed: () {
                                  _showEditIngredients(
                                      eExtras: extras, type: 2);
                                }),
                          )
                        : Center(),
                    Container(
                      width: 200,
                      child: RaisedButton.icon(
                          icon: Icon(Icons.save),
                          padding: EdgeInsets.all(15),
                          label:
                              Text(widget.isMeals ? 'Save Meal' : 'Save Menu'),
                          onPressed: () => _saveMeal(false)),
                    ),
                    // Container(
                    //   width: 200,
                    //   child: RaisedButton.icon(
                    //       icon: Icon(Icons.save),
                    //       padding: EdgeInsets.all(15),
                    //       label: Text('delete Menu'),
                    //       onPressed: () async {
                    //         try {
                    //           fileManagement.writeFile(menuJsonFile, '');
                    //         } catch (error) {
                    //           print('Error saving meal: $error');
                    //           return false;
                    //         }
                    //         return true;
                    //       }),
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
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
                    SizedBox(height: 400),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Show a menu to choose wich ingredients are in the meal
  _showEditIngredients(
      {List<Ingredient> eIngredients,
      List<Meal> eMeals,
      List<Extra> eExtras,
      int type}) {
    String ingredientOrMeal; // = eIsIngredients ? 'ingredients' : 'meals';
    bool listIsEmpty = false;
    int listLenght = 0;
    switch (type) {
      case 0:
        ingredientOrMeal = 'ingredients';
        if (eIngredients.length == 0) {
          listIsEmpty = true;
        } else {
          listLenght = eIngredients.length;
        }
        break;
      case 1:
        ingredientOrMeal = 'meals';
        if (eMeals.length == 0) {
          listIsEmpty = true;
        } else {
          listLenght = eMeals.length;
        }
        break;
      case 2:
        ingredientOrMeal = 'extras';
        if (eExtras.length == 0) {
          listIsEmpty = true;
        } else {
          listLenght = eExtras.length;
        }
        break;
      default:
        ingredientOrMeal = 'ingredients';
    }

    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          itemCount: listLenght,
                          itemBuilder: (BuildContext context, int index) {
                            switch (type) {
                              case 0:
                                return addIngredientListTile(
                                    eIngredients[index], setModalState);
                                break;
                              case 1:
                                return addMealListTile(
                                    eMeals[index], setModalState);
                                break;
                              case 2:
                                return addExtraListTile(
                                    eExtras[index], setModalState);
                                break;
                              default:
                                ingredientOrMeal = 'ingredients';
                            }
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
      int nullIndex = _selectedIngredients
          .indexWhere((ingredient) => ingredient.amountInGrams == null);

      if (nullIndex == -1) {
        _formKey.currentState.save();
        double _finalSalePrice;
        int _finalMinutesToMake = 0;
        int _hourPrice =
            await _sharedValueHandler.getIntSharedP('hourPrice', 100);
        int _vatPercent =
            await _sharedValueHandler.getIntSharedP('VATPercent', 25);
        if (widget.isMeals) _finalMinutesToMake = int.parse(_minutesToMake);

        double _totalPrice = 0;
        _selectedIngredients.forEach((e) {
          if (e.measureUnit == 'ml' || e.measureUnit == 'g') {
            _totalPrice += (e.amountInGrams) * e.kgPrice;
          } else
            _totalPrice += (e.amountInGrams / 1000) * e.kgPrice;
        });

        if (!widget.isMeals) {
          _selectedMeals.forEach((m) {
            _totalPrice += m.totalCost(_hourPrice) * m.amount;
          });

          _selectedExtras.forEach((m) {
            _totalPrice += m.costPrice * m.amount;
          });
        }

        if (_salePriceChosen) {
          String tempSale = _salePrice.replaceAll(',', '.');
          _finalSalePrice = double.parse(tempSale);
        } else {
          String tempProfit = _profitMargin.replaceAll(',', '.');

          if (widget.isMeals) {
            _totalPrice = _totalPrice + (_hourPrice / 60 * _finalMinutesToMake);
          }

          //_finalSalePrice = _totalPrice / (1 - double.parse(tempProfit) / 100);

          _finalSalePrice =
              (((double.parse(tempProfit) / 100) * _totalPrice) + _totalPrice) *
                  (_vatPercent / 100 + 1);
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
          newMeal = Meal(newID, _name, _finalSalePrice, _selectedIngredients,
              _finalMinutesToMake,
              amount: 1);
          // print(newMeal);
        } else {
          newMenu = Menu(newID, _name, _finalSalePrice, _selectedIngredients,
              _selectedMeals, _selectedExtras);
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
          if (!dublicate) {
            if (widget.editMode ?? false) {
              if (widget.isMeals) {
                Navigator.of(context).pop(newMeal);
              } else {
                Navigator.of(context).pop(newMenu);
              }
            } else {
              if (widget.isMeals) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        SingleMeal(meal: newMeal, isMeal: true)));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        SingleMeal(menu: newMenu, isMeal: false)));
              }
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(builder: (context) => MyHomePage()),
              //     (route) => false);
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

        String menuFileContent = await fileManagement.readFile(menuJsonFile);
        List<Menu> allMenusFromFile =
            objManager.jsonToListMenu(menuFileContent);

        //Update data of meals in menus
        allMenusFromFile.forEach((menu) {
          int menuEditIndex =
              menu.meals.indexWhere((element) => element.id == newMeal.id);
          if (menuEditIndex != -1) {
            Meal newMealWGrams = newMeal;
            int amount = menu.meals[menuEditIndex].amount;
            newMealWGrams.amount = amount;
            menu.meals[menuEditIndex] = newMealWGrams;
          }
        });
        fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
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
  Widget ingredientListTile(
      Ingredient ltIngredient, void Function(void Function()) setModalState) {
    List<String> amountNoDot =
        ltIngredient.amountInGrams?.toString()?.split('.');
    TextEditingController tec = TextEditingController(
        text: ltIngredient.amountInGrams?.toString() ?? '');
    if (amountNoDot != null) {
      tec = TextEditingController(text: amountNoDot[0] ?? '');
    }
    return Card(
      child: ListTile(
          title: Text(ltIngredient.name),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                padding: EdgeInsets.all(5),
                width: 80,
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
            Text(ltIngredient.measureUnit == 'Kg' ? 'g  ' : 'ml'),
            Container(
              width: 20,
              // height: 30,
              
              child: IconButton(
                iconSize: 15,
                icon: Icon(Icons.close),
                onPressed: () {
                  _onIngredientSelected(false, ltIngredient, setModalState);
                },
              ),
            )
          ])),
    );
  }

  Widget mealListTile(
      Meal ltMeal, void Function(void Function()) setModalState) {
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
                    int mealIndex = _selectedMeals
                        .indexWhere((meal) => meal.id == ltMeal.id);
                    _selectedMeals[mealIndex].amount = ltMeal.amount;
                  }
                }),
            Text('${ltMeal.amount}'),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    ltMeal.amount++;
                  });
                  int mealIndex =
                      _selectedMeals.indexWhere((meal) => meal.id == ltMeal.id);
                  _selectedMeals[mealIndex].amount = ltMeal.amount;
                }),
            Container(
              width: 15,
              height: 30,
              child: IconButton(
                iconSize: 15,
                icon: Icon(Icons.close),
                onPressed: () {
                  _onMealSelected(false, ltMeal, setModalState);
                },
              ),
            )
          ])),
    );
  }

  Widget extraListTile(
      Extra ltExtra, void Function(void Function()) setModalState) {
    return Card(
      child: ListTile(
          title: Text(ltExtra.name),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (ltExtra.amount > 1) {
                    setState(() {
                      ltExtra.amount--;
                    });
                    int extraIndex = _selectedExtras
                        .indexWhere((extra) => extra.id == ltExtra.id);
                    _selectedExtras[extraIndex].amount = ltExtra.amount;
                  }
                }),
            Text('${ltExtra.amount}'),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    ltExtra.amount++;
                  });
                  int extraIndex = _selectedExtras
                      .indexWhere((extra) => extra.id == ltExtra.id);
                  _selectedExtras[extraIndex].amount = ltExtra.amount;
                }),
            Container(
              width: 15,
              height: 30,
              child: IconButton(
                iconSize: 15,
                icon: Icon(Icons.close),
                onPressed: () {
                  _onExtraSelected(false, ltExtra, setModalState);
                },
              ),
            )
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

  Widget addExtraListTile(Extra aExtra, Function setModalState) {
    return Card(
      child: CheckboxListTile(
        title: Text(aExtra.name),
        value: _selectedExtras.indexWhere((e) => e.id == aExtra.id) != -1,
        onChanged: (bool selected) {
          _onExtraSelected(selected, aExtra, setModalState);
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

  void _onExtraSelected(bool mSelected, Extra sExtra, Function setModalState) {
    if (mSelected == true) {
      setModalState(() {
        sExtra.amount = 1;
        _selectedExtras.add(sExtra);
      });
    } else {
      setModalState(() {
        _selectedExtras.removeWhere((e) => e.id == sExtra.id);
      });
    }
  }

  Widget itemListTitle(String _title, String _altTitle, int listLenght) {
    return Text(
      listLenght == 0 ? _altTitle : _title,
      style: TextStyle(
          fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w300),
    );
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

  String validateInt(String value) {
    try {
      int.parse(value);
      return null;
    } catch (error) {
      return "Invalid number.";
    }
  }
}
