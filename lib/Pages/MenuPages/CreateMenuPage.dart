import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/CreateElementLogic.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ValidateValues.dart';
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

  Future _getElementsFuture;

  String ingredientJsonFile = config.ingredientJsonFile;
  String mealJsonFile = config.mealJsonFile;
  String menuJsonFile = config.menuJsonFile;
  String extraJsonFile = config.extraJsonFile;
  final ValidateValues _validateValues = ValidateValues();
  final CreateElementLogic _createElementLogic = CreateElementLogic();

  Future<bool> getElementsFromFile() async {
    String ingredientFileContent = await fileManagement.readFile(ingredientJsonFile);
    String mealFileContent = await fileManagement.readFile(mealJsonFile);
    String extraFileContent = await fileManagement.readFile(extraJsonFile);
    ingredients = objManager.jsonToListIngredient(ingredientFileContent);
    meals = objManager.jsonToListMeal(mealFileContent);
    extras = objManager.jsonToListExtra(extraFileContent);
    return true;
  }

//Check if menu is being edited and insert object.
  initEditMenuMode() {
    String tempSale;
    _name = widget.editMenu.name;
    tempSale = widget.editMenu.salePrice.toString();
    _salePrice = tempSale.replaceAll('.', ',');
    _selectedIngredients = widget.editMenu.ingredients?.map((e) => Ingredient.clone(e))?.toList();
    _selectedMeals = widget.editMenu.meals?.map((e) => Meal.clone(e))?.toList();
    _selectedExtras = widget.editMenu.extras?.map((e) => Extra.clone(e))?.toList();
    _nameController.text = _name;
    _salePriceController.text = _salePrice;
  }

  @override
  void initState() {
    super.initState();
    _getElementsFuture = getElementsFromFile();
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
                            textInputType: TextInputType.numberWithOptions(decimal: true),
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
                          AddElementModule(selectedElement: _selectedExtras, allElements: extras, title: 'Extras', setState: setState),
                          AddElementModule(selectedElement: _selectedMeals, allElements: meals, title: 'Meals', setState: setState),
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
                                    elementType: ElementTypes.menu,
                                    context: context,
                                    editId: widget.editMenu?.id,
                                    selectedExtras: _selectedExtras,
                                    selectedMeals: _selectedMeals,
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

  Widget itemListTitle(String _title, String _altTitle, int listLenght) {
    return Text(
      listLenght == 0 ? _altTitle : _title,
      style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w300),
    );
  }
}
