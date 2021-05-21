import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/CreateElementLogic.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ValidateValues.dart';
import 'package:profit_calculator/Model/Catering.dart';
import 'package:profit_calculator/Model/ElementTypes.dart';

import 'package:profit_calculator/Model/Extra.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/AddElementModule.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/CreateElementTextField.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import '../../Model/Ingredient.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class CreateCateringPage extends StatefulWidget {
  final bool editMode;
  final Catering editCatering;
  CreateCateringPage({this.editMode, this.editCatering});

  @override
  _CreateCateringPageState createState() => _CreateCateringPageState();
}

class _CreateCateringPageState extends State<CreateCateringPage> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _salePrice;

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();

  List<Ingredient> _selectedIngredients = <Ingredient>[];
  List<Menu> _selectedMenus = <Menu>[];
  List<Meal> _selectedMeals = <Meal>[];
  List<Extra> _selectedExtras = <Extra>[];
  List<Ingredient> ingredients = <Ingredient>[];
  List<Meal> meals = <Meal>[];
  List<Menu> menus = <Menu>[];
  List<Extra> extras = <Extra>[];
  TextEditingController _salePriceController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  Future _getElementsFuture;

  String ingredientJsonFile = config.ingredientJsonFile;
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;
  String extraJsonFile = config.extraJsonFile;
  final ValidateValues _validateValues = ValidateValues();
  final CreateElementLogic _createElementLogic = CreateElementLogic();

  Future<bool> getElementsFromFile() async {
    String ingredientFileContent =
        await fileManagement.readFile(ingredientJsonFile);
    String mealFileContent = await fileManagement.readFile(mealJsonFile);
    String extraFileContent = await fileManagement.readFile(extraJsonFile);
    String menuFileContent = await fileManagement.readFile(menuJsonFile);

    ingredients = objManager.jsonToListIngredient(ingredientFileContent);
    meals = objManager.jsonToListMeal(mealFileContent);
    extras = objManager.jsonToListExtra(extraFileContent);
    menus = objManager.jsonToListMenu(menuFileContent);
    return true;
  }

//Check if menu is being edited and insert object.
  initEditCateringMode() {
    String tempSale;
    _name = widget.editCatering.name;
    tempSale = widget.editCatering.salePrice.toString();
    _salePrice = tempSale.replaceAll('.', ',');
    _selectedIngredients = widget.editCatering.ingredients
        ?.map((e) => Ingredient.clone(e))
        ?.toList();
    _selectedMeals =
        widget.editCatering.meals?.map((e) => Meal.clone(e))?.toList();
    _selectedMenus =
        widget.editCatering.menus?.map((e) => Menu.clone(e))?.toList();
    _selectedExtras =
        widget.editCatering.extras?.map((e) => Extra.clone(e))?.toList();
    _nameController.text = _name;
    _salePriceController.text = _salePrice;
  }

  @override
  void initState() {
    super.initState();
    _getElementsFuture = getElementsFromFile();

    if (widget.editMode ?? false) {
      initEditCateringMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('Create Catering'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: FutureBuilder(
                future: _getElementsFuture,
                initialData: '',
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return MyLoadingCircle(500);
                  }
                  return Container(
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
                            allowedInput: r'[0-9.,]',
                            textInputType:
                                TextInputType.numberWithOptions(decimal: true),
                            textEditingController: _salePriceController,
                            validate: _validateValues.validateDouble,
                            setValue: (value) => _salePrice = value,
                          ),
                          AddElementModule(
                              selectedElement: _selectedIngredients,
                              allElements: ingredients,
                              title: 'Ingredients',
                              wGramInput: true,
                              setState: setState),
                          AddElementModule(
                              selectedElement: _selectedExtras,
                              allElements: extras,
                              title: 'Extras',
                              setState: setState),
                          AddElementModule(
                              selectedElement: _selectedMeals,
                              allElements: meals,
                              title: 'Meals',
                              setState: setState),
                          AddElementModule(
                              selectedElement: _selectedMenus,
                              allElements: menus,
                              title: 'Menus',
                              setState: setState),
                          MyIconButton(
                              tileIcon: Icon(Icons.save),
                              compact: true,
                              tileTitle: 'Save Menu',
                              myOnPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();

                                  _createElementLogic.saveElement(
                                    selectedIngredients: _selectedIngredients,
                                    salePrice: _salePrice,
                                    name: _name,
                                    editMode: widget.editMode,
                                    elementType: ElementTypes.catering,
                                    context: context,
                                    editId: widget.editCatering?.id,
                                    selectedExtras: _selectedExtras,
                                    selectedMeals: _selectedMeals,
                                    selectedMenus: _selectedMenus,
                                  );
                                }
                              }),
                          SizedBox(height: 400),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
