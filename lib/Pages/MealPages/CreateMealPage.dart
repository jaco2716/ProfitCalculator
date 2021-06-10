import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Handlers/CreateElementLogic.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ValidateValues.dart';
import 'package:profit_calculator/Model/ElementTypes.dart';

import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/AddElementModule.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/CreateElementTextField.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import '../../Model/Ingredient.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class CreateMealPage extends StatefulWidget {
  final bool editMode;
  final Meal editMeal;
  CreateMealPage({this.editMode, this.editMeal});

  @override
  _CreateMealPageState createState() => _CreateMealPageState();
}

class _CreateMealPageState extends State<CreateMealPage> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _salePrice;
  String _minutesToMake;

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();

  List<Ingredient> _selectedIngredients = <Ingredient>[];
  List<Ingredient> ingredients = <Ingredient>[];
  TextEditingController _salePriceController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _minutesToMakeController = TextEditingController();

  Future _getElementsFuture;

  // String mealJsonFile = config.mealJsonFile;
  String ingredientJsonFile = config.ingredientJsonFile;
  String menuJsonFile = config.menuJsonFile;
  final ValidateValues _validateValues = ValidateValues();
  final CreateElementLogic _createElementLogic = CreateElementLogic();

  //Get all ingredients from file
  Future<bool> getElementsFromFile() async {
    String fileContent = await fileManagement.readFile(ingredientJsonFile);
    ingredients = objManager.jsonToListIngredient(fileContent);
    return true;
  }

//Check if menu is being edited and insert object.
  initEditMealMode() {
    String tempSale;
    _name = widget.editMeal.name;
    tempSale = widget.editMeal.salePrice.toString();
    _salePrice = tempSale.replaceAll('.', ',');
    _minutesToMake = widget.editMeal.minutesToMake.toString();
    _selectedIngredients =
        widget.editMeal.ingredients?.map((e) => Ingredient.clone(e))?.toList();
    _nameController.text = _name;
    _salePriceController.text = _salePrice;
    _minutesToMakeController.text = _minutesToMake;
  }

  @override
  void initState() {
    super.initState();
    _getElementsFuture = getElementsFromFile();
    if (widget.editMode ?? false) {
      initEditMealMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('Create Meal'),
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
                            title: 'Name *',
                            myValue: _name,
                            textEditingController: _nameController,
                            validate: _validateValues.validateString,
                            setValue: (value) => _name = value,
                          ),
                          CreateElementTextField(
                            title: 'Sale Price *',
                            myValue: _salePrice,
                            allowedInput: r'[0-9.,]',
                            textInputType:
                                TextInputType.numberWithOptions(decimal: true),
                            textEditingController: _salePriceController,
                            validate: _validateValues.validateDouble,
                            setValue: (value) => _salePrice = value,
                          ),
                          CreateElementTextField(
                            title: 'Minutes to make meal',
                            myValue: _minutesToMake,
                            allowedInput: r'[0-9.,]',
                            textInputType: TextInputType.number,
                            textEditingController: _minutesToMakeController,
                            validate: (value) => _validateValues.validateInt(value, canBeNull: true),
                            setValue: (value) => _minutesToMake = value,
                          ),
                          AddElementModule(
                              selectedElement: _selectedIngredients,
                              allElements: ingredients,
                              title: 'Ingredients',
                              wGramInput: true,
                              setState: setState),
                          Divider(thickness: 1),
                          MyIconButton(
                              tileIcon: Icon(Icons.save),
                              compact: true,
                              tileTitle: 'Save Meal',
                              myOnPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();

                                  _createElementLogic.saveElement(
                                    selectedIngredients: _selectedIngredients,
                                    salePrice: _salePrice,
                                    name: _name,
                                    editMode: widget.editMode,
                                    elementType: ElementTypes.meal,
                                    minutesToMake: _minutesToMake,
                                    context: context,
                                    editId: widget.editMeal?.id,
                                  );
                                }else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields')));
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
