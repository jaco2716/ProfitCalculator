import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/CreateElementLogic.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Handlers/ValidateValues.dart';

import 'package:profit_calculator/Model/Extra.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/CreateElementTextField.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/ElementAmountInputListTile.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/ElementGramInputListTile.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import '../../Model/Ingredient.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class CreateMenuPage extends StatefulWidget {
  final bool editMode;
  final Menu editMenu;
  CreateMenuPage({this.editMode, this.editMenu});

  @override
  _CreateMenuPageState createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
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
  TextEditingController _salePriceController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  String ingredientJsonFile = config.ingredientJsonFile;
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;
  String extraJsonFile = config.extraJsonFile;
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  final ValidateValues _validateValues = ValidateValues();
  final CreateElementLogic _createElementLogic = CreateElementLogic();

  List<Ingredient> ingreTemp = <Ingredient>[];

  //Get all ingredients from file
  getIngredientsFromFile() async {
    String fileContent = await fileManagement.readFile(ingredientJsonFile);
    List<Ingredient> tempIngredients = <Ingredient>[];
    tempIngredients = objManager.jsonToListIngredient(fileContent);
    ingredients = tempIngredients;
  }

  getMealsFromFile() async {
    String mealFileContent = await fileManagement.readFile(mealJsonFile);
    String extraFileContent = await fileManagement.readFile(extraJsonFile);
    meals = objManager.jsonToListMeal(mealFileContent);
    extras = objManager.jsonToListExtra(extraFileContent);
  }

//Check if menu is being edited and insert object.
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
    _nameController.text = _name;
    _salePriceController.text = _salePrice;
  }

  @override
  void initState() {
    super.initState();
    getIngredientsFromFile();
    getMealsFromFile();

    if (widget.editMode ?? false) {
      initEditMenuMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('Create Menu'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(30),
              constraints: BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
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
                      title: 'Sale Price',
                      myValue: _salePrice,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textEditingController: _salePriceController,
                      validate: _validateValues.validateDouble,
                      setValue: (value) => _salePrice = value,
                    ),
                    Divider(thickness: 1),
                    itemListTitle('Ingredients:', 'No ingredients added.',
                        _selectedIngredients.length),
                    Container(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: _selectedIngredients.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ElementGramInputListTile(
                              ingredient: _selectedIngredients[index],
                              myOnPressed: () =>
                                  _createElementLogic.onElementSelected(
                                      false,
                                      _selectedIngredients[index].id,
                                      setState,
                                      _selectedIngredients,
                                      ingredients),
                              myOnChanged: (value) =>
                                  _createElementLogic.setIngredientAmount(
                                      value,
                                      _selectedIngredients[index].id,
                                      _selectedIngredients));
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                    MyIconButton(
                      tileIcon: Icon(Icons.add),
                      buttonColor: Colors.pink,
                      compact: true,
                      height: 60,
                      tileTitle: 'Add Ingredients',
                      myOnPressed: () => _createElementLogic.showEditElements(
                          context: context,
                          setState: setState,
                          elements: ingredients,
                          selectedElements: _selectedIngredients,
                          title: 'Ingredients'),
                    ),
                    Divider(thickness: 1),
                    itemListTitle(
                        'Meals:', 'No meals added.', _selectedMeals.length),
                    Container(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: _selectedMeals.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ElementAmountInputListTile(
                              element: _selectedMeals[index],
                              myOnPressed: () =>
                                  _createElementLogic.onElementSelected(
                                      false,
                                      _selectedMeals[index].id,
                                      setState,
                                      _selectedMeals,
                                      meals),
                              myOnAmountChange: (value) =>
                                  _createElementLogic.changeElementAmount(
                                      _selectedMeals[index],
                                      _selectedMeals,
                                      value,
                                      setState));
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                    MyIconButton(
                      tileIcon: Icon(Icons.add),
                      buttonColor: Colors.pink,
                      compact: true,
                      height: 60,
                      tileTitle: 'Add Meals',
                      myOnPressed: () => _createElementLogic.showEditElements(
                          context: context,
                          setState: setState,
                          elements: meals,
                          selectedElements: _selectedMeals,
                          title: 'Meals'),
                    ),
                    Divider(thickness: 1),
                    itemListTitle(
                        'Extras:', 'No extras added.', _selectedExtras.length),
                    Container(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: _selectedExtras.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ElementAmountInputListTile(
                              element: _selectedExtras[index],
                              myOnPressed: () =>
                                  _createElementLogic.onElementSelected(
                                      false,
                                      _selectedExtras[index].id,
                                      setState,
                                      _selectedExtras,
                                      extras),
                              myOnAmountChange: (value) =>
                                  _createElementLogic.changeElementAmount(
                                      _selectedExtras[index],
                                      _selectedExtras,
                                      value,
                                      setState));
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ),
                    MyIconButton(
                        tileIcon: Icon(Icons.add),
                        buttonColor: Colors.pink,
                        compact: true,
                        height: 60,
                        tileTitle: 'Add Extras',
                        myOnPressed: () => _createElementLogic.showEditElements(
                            context: context,
                            setState: setState,
                            elements: extras,
                            selectedElements: _selectedExtras,
                            title: 'Extras')),
                    MyIconButton(
                        tileIcon: Icon(Icons.save),
                        compact: true,
                        tileTitle: 'Save Menu',
                        myOnPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();

                            _createElementLogic.saveMenu(
                              selectedIngredients: _selectedIngredients,
                              salePrice: _salePrice,
                              name: _name,
                              editMode: widget.editMode,
                              context: context,
                              editId: widget.editMenu?.id,
                              selectedExtras: _selectedExtras,
                              selectedMeals: _selectedMeals,
                            );
                          }
                        }),
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

  Widget itemListTitle(String _title, String _altTitle, int listLenght) {
    return Text(
      listLenght == 0 ? _altTitle : _title,
      style: TextStyle(
          fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w300),
    );
  }

// Create final menu object and save it
  // _saveMenu() async {
  //   if (_formKey.currentState.validate()) {
  //     int nullIndex = _selectedIngredients
  //         .indexWhere((ingredient) => ingredient.amountInGrams == null);

  //     if (nullIndex == -1) {
  //       _formKey.currentState.save();
  //       double _finalSalePrice;
  //       int _hourPrice =
  //           await _sharedValueHandler.getIntSharedP('hourPrice', 100);
  //       int _vatPercent =
  //           await _sharedValueHandler.getIntSharedP('VATPercent', 25);

  //       double _totalPrice = 0;
  //       _selectedIngredients.forEach((e) {
  //         if (e.measureUnit == 'ml' || e.measureUnit == 'g') {
  //           _totalPrice += (e.amountInGrams) * e.kgPrice;
  //         } else
  //           _totalPrice += (e.amountInGrams / 1000) * e.kgPrice;
  //       });

  //       _selectedMeals.forEach((m) {
  //         _totalPrice += m.totalCost(_hourPrice) * m.amount;
  //       });

  //       _selectedExtras.forEach((m) {
  //         _totalPrice += m.costPrice * m.amount;
  //       });

  //       if (_salePriceChosen) {
  //         String tempSale = _salePrice.replaceAll(',', '.');
  //         _finalSalePrice = double.parse(tempSale);
  //       } else {
  //         String tempProfit = _profitMargin.replaceAll(',', '.');

  //         _finalSalePrice =
  //             (((double.parse(tempProfit) / 100) * _totalPrice) + _totalPrice) *
  //                 (_vatPercent / 100 + 1);
  //       }

  //       _finalSalePrice = (_finalSalePrice * 100).roundToDouble() / 100;

  //       int newID;
  //       if (widget.editMode ?? false) {
  //         newID = widget.editMenu.id;
  //       } else
  //         newID = DateTime.now().millisecondsSinceEpoch;
  //       Menu newMenu;

  //       newMenu = Menu(newID, _name, _finalSalePrice, _selectedIngredients,
  //           _selectedMeals, _selectedExtras);

  //       bool saveSucess = false;

  //       saveSucess = await _saveMenuToFile(newMenu);

  //       if (saveSucess) {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text(_name + ' has been saved.'),
  //         ));

  //         if (widget.editMode ?? false) {
  //           Navigator.of(context).pop(newMenu);
  //         } else {
  //           Navigator.of(context).pushReplacement(MaterialPageRoute(
  //               builder: (context) => SingleMenuPage(newMenu)));
  //         }
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('Something went wrong, please try again.'),
  //         ));
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Please fill out all ingredients.'),
  //       ));
  //     }
  //   }
  // }

  // Future<bool> _saveMenuToFile(Menu newMenu) async {
  //   try {
  //     String fileContent = await fileManagement.readFile(menuJsonFile);
  //     List<Menu> allMenusFromFile = objManager.jsonToListMenu(fileContent);
  //     if (widget.editMode ?? false) {
  //       int editIndex =
  //           allMenusFromFile.indexWhere((element) => element.id == newMenu.id);
  //       allMenusFromFile[editIndex] = newMenu;
  //     } else {
  //       allMenusFromFile.add(newMenu);
  //     }
  //     fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
  //   } catch (error) {
  //     print('Error saving menu: $error');
  //     return false;
  //   }
  //   return true;
  // }

}
