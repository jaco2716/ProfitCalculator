import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Model/Catering.dart';
import 'package:profit_calculator/Model/ElementTypes.dart';
import 'package:profit_calculator/Model/Extra.dart';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/AddElementListTile.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/Pages/CateringPages/SingleCateringPage.dart';
import 'package:profit_calculator/Pages/MealPages/SingleMealPage.dart';
import 'package:profit_calculator/Pages/MenuPages/SingleMenuPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class CreateElementLogic {
  // final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  final String menuJsonFile = config.menuJsonFile;
  final String extraJsonFile = config.extraJsonFile;
  final String cateringJsonFile = config.cateringJsonFile;
// Add or remove the ingredient pressed to a new list of selected ingredients
  void onElementSelected(bool elementSelected, int elementId, Function setModalState, List<dynamic> selectedElements, List<dynamic> allElements) {
    if (elementSelected == true) {
      setModalState(() {
        selectedElements.add(allElements.firstWhere((e) => e.id == elementId));
      });
    } else {
      setModalState(() {
        selectedElements.removeWhere((e) => e.id == elementId);
      });
    }
  }

  //Give ingredients an amountInGrams value
  void setIngredientAmount(String text, int itemId, List<Ingredient> selIngredients) {
    try {
      int ingredientIndex = selIngredients.indexWhere((ingredient) => ingredient.id == itemId);
      if (text != '') {
        double number = double.parse(text);
        selIngredients[ingredientIndex].amountInGrams = number;
      } else {
        selIngredients[ingredientIndex].amountInGrams = null;
      }
    } catch (error) {
    print('takeNumber Error: ' + error.toString());
    }
  }

  void changeElementAmount(dynamic element, List<dynamic> selectedElements, value, void Function(Function()) setState) {
    int tempValue = element.amount + value;
    if (tempValue < 1) {
      return;
    }
    setState(() {
      element.amount += value;
    });
    int elementIndex = selectedElements.indexWhere((e) => e.id == element.id);
    selectedElements[elementIndex].amount = element.amount;
  }

  void showEditElements({
    @required List<dynamic> elements,
    @required List<dynamic> selectedElements,
    @required String title,
    @required BuildContext context,
    @required void Function(Function()) setState,
  }) {
    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(children: [
                AppBar(
                  title: Text('Add $title'),
                  backgroundColor: Colors.orange,
                  leading: Center(),
                ),
                Container(
                  height: (MediaQuery.of(context).size.height - 200),
                  child: elements.length == 0
                      ? Center(
                          child: Text('You have no $title.\nCreate $title in the menu.\n\n\n',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              )))
                      : ListView.builder(
                          itemCount: elements.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AddElementListTile(
                                element: elements[index], setModalState: setModalState, selectedElements: selectedElements, allElements: elements);
                          },
                        ),
                ),
                MyIconButton(
                  tileIcon: Icon(Icons.done),
                  tileTitle: 'Done',
                  compact: true,
                  myOnPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
                SizedBox(height: 25),
              ]),
            );
          },
        );
      },
      context: context,
    );
  }

  saveElement({
    @required List<Ingredient> selectedIngredients,
    @required String salePrice,
    @required String name,
    @required bool editMode,
    @required BuildContext context,
    @required ElementTypes elementType,
    String discount,
    String minutesToMake,
    int editId,
    List<Meal> selectedMeals,
    List<Extra> selectedExtras,
    List<Menu> selectedMenus,
  }) async {
    int nullIndex = selectedIngredients.indexWhere((ingredient) => ingredient.amountInGrams == null);

    if (nullIndex == -1) {
      int _finalMinutesToMake = 0;
      int newID;
      bool saveSucess = false;
      int _finalDiscount = 0;
      double _finalSalePrice = double.parse(salePrice.replaceAll(',', '.'));
      _finalSalePrice = (_finalSalePrice * 100).roundToDouble() / 100;
      if (editMode ?? false)
        newID = editId;
      else
        newID = DateTime.now().millisecondsSinceEpoch;

      switch (elementType) {
        case ElementTypes.meal:
          if (minutesToMake != '') _finalMinutesToMake = int.parse(minutesToMake);
          Meal newElement = Meal(newID, name, _finalSalePrice, selectedIngredients, _finalMinutesToMake);
          saveSucess = await _saveMealToFile(newElement, editMode);
          navigateAfterSave(saveSucess, context, name, editMode, newElement, SingleMealPage(newElement));
          break;
        case ElementTypes.menu:
          Menu newElement = Menu(newID, name, _finalSalePrice, selectedIngredients, selectedMeals, selectedExtras);
          saveSucess = await _saveMenuToFile(newElement, editMode);
          navigateAfterSave(saveSucess, context, name, editMode, newElement, SingleMenuPage(newElement));
          break;
        case ElementTypes.catering:
          if (discount != '') _finalDiscount = int.parse(discount);
          Catering newElement =
              Catering(newID, name, _finalSalePrice, _finalDiscount, selectedIngredients, selectedMeals, selectedExtras, selectedMenus);
          saveSucess = await _saveCateringToFile(newElement, editMode);
          navigateAfterSave(saveSucess, context, name, editMode, newElement, SingleCateringPage(newElement));
          break;
        default:
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all ingredients.'),
      ));
    }
  }

  void navigateAfterSave(bool saveSucess, BuildContext context, String name, bool editMode, newElement, Widget navigateTo) {
    if (saveSucess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(name + ' has been saved.'),
      ));

      if (editMode ?? false) {
        Navigator.of(context).pop(newElement);
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => navigateTo));
        // } else {
        //   Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       builder: (context) => SingleMenuPage(newElement)));
        // }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong, please try again.'),
      ));
    }
  }

  Future<bool> _saveMealToFile(Meal newMeal, bool editMode) async {
    try {
      String fileContent = await fileManagement.readFile(mealJsonFile);
      List<Meal> allMealsFromFile = objManager.jsonToListMeal(fileContent);
      if (editMode ?? false) {
        int editIndex = allMealsFromFile.indexWhere((element) => element.id == newMeal.id);
        allMealsFromFile[editIndex] = newMeal;

        String menuFileContent = await fileManagement.readFile(menuJsonFile);
        List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
        String cateringFileContent = await fileManagement.readFile(cateringJsonFile);
        List<Catering> allCateringsFromFile = objManager.jsonToListCatering(cateringFileContent);

        //Update data of meals in menus
        _updateMealsInFile(allMenusFromFile, newMeal);
        _updateMealsInFile(allCateringsFromFile, newMeal);
        allCateringsFromFile.forEach((e) {
          _updateMealsInFile(e.menus, newMeal);
        });
        
        fileManagement.writeFile(menuJsonFile, jsonEncode(allMenusFromFile));
        fileManagement.writeFile(cateringJsonFile, jsonEncode(allCateringsFromFile));
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

  Future<bool> _saveMenuToFile(Menu newMenu, bool editMode) async {
    try {
      String fileContent = await fileManagement.readFile(menuJsonFile);
      List<Menu> allMenusFromFile = objManager.jsonToListMenu(fileContent);
      if (editMode ?? false) {
        int editIndex = allMenusFromFile.indexWhere((element) => element.id == newMenu.id);
        allMenusFromFile[editIndex] = newMenu;

        String cateringFileContent = await fileManagement.readFile(cateringJsonFile);
        List<Catering> allCateringsFromFile = objManager.jsonToListCatering(cateringFileContent);

        _updateMenusInFile(allCateringsFromFile, newMenu);
        fileManagement.writeFile(cateringJsonFile, jsonEncode(allCateringsFromFile));
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

  Future<bool> _saveCateringToFile(Catering newCatering, bool editMode) async {
    try {
      String fileContent = await fileManagement.readFile(cateringJsonFile);
      List<Catering> allCateringsFromFile = objManager.jsonToListCatering(fileContent);
      if (editMode ?? false) {
        int editIndex = allCateringsFromFile.indexWhere((element) => element.id == newCatering.id);
        allCateringsFromFile[editIndex] = newCatering;
      } else {
        allCateringsFromFile.add(newCatering);
      }
      fileManagement.writeFile(cateringJsonFile, jsonEncode(allCateringsFromFile));
    } catch (error) {
    print('Error saving catering: $error');
      return false;
    }
    return true;
  }

  _updateMealsInFile(List<dynamic> updateElementList, Meal newMeal) {
    updateElementList.forEach((element) {
      int elementEditIndex = element.meals.indexWhere((element) => element.id == newMeal.id);
      if (elementEditIndex != -1) {
        Meal newMealWAmount = Meal.clone(newMeal);
        newMealWAmount.amount = element.meals[elementEditIndex].amount;
        element.meals[elementEditIndex] = newMealWAmount;
      }
    });
  }

  _updateMenusInFile(List<dynamic> updateElementList, Menu newMenu) {
    updateElementList.forEach((element) {
      int elementEditIndex = element.menus.indexWhere((element) => element.id == newMenu.id);
      if (elementEditIndex != -1) {
        Menu newMenuWAmount = Menu.clone(newMenu);
        newMenuWAmount.amount = element.menus[elementEditIndex].amount;
        element.menus[elementEditIndex] = newMenuWAmount;
      }
    });
  }
}
