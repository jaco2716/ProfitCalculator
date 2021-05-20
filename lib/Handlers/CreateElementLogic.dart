import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Model/Extra.dart';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Meal.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/AddElementListTile.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
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
// Add or remove the ingredient pressed to a new list of selected ingredients
  void onElementSelected(
      bool elementSelected,
      int elementId,
      Function setModalState,
      List<dynamic> selectedElements,
      List<dynamic> allElements) {
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
  void setIngredientAmount(
      String text, int itemId, List<Ingredient> selIngredients) {
    try {
      int ingredientIndex =
          selIngredients.indexWhere((ingredient) => ingredient.id == itemId);
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

  void changeElementAmount(dynamic element, List<dynamic> selectedElements,
      value, void Function(Function()) setState) {
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
                  backgroundColor: Colors.pink,
                  leading: Center(),
                ),
                Container(
                  height: (MediaQuery.of(context).size.height - 200),
                  child: elements.length == 0
                      ? Center(
                          child: Text(
                              'You have no $title.\nCreate $title in the menu.\n\n\n',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              )))
                      : ListView.builder(
                          itemCount: elements.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AddElementListTile(
                                element: elements[index],
                                setModalState: setModalState,
                                selectedElements: selectedElements,
                                allElements: elements);
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

  saveMenu({
    @required List<Ingredient> selectedIngredients,
    @required String salePrice,
    @required String name,
    @required bool editMode,
    @required BuildContext context,
    int editId,
    List<Meal> selectedMeals,
    List<Extra> selectedExtras,
  }) async {
    int nullIndex = selectedIngredients
        .indexWhere((ingredient) => ingredient.amountInGrams == null);

    if (nullIndex == -1) {
      String tempSale = salePrice.replaceAll(',', '.');
      double _finalSalePrice = double.parse(tempSale);

      _finalSalePrice = (_finalSalePrice * 100).roundToDouble() / 100;

      int newID;
      if (editMode ?? false) {
        newID = editId;
      } else
        newID = DateTime.now().millisecondsSinceEpoch;
      Menu newMenu;

      newMenu = Menu(newID, name, _finalSalePrice, selectedIngredients,
          selectedMeals, selectedExtras);

      bool saveSucess = false;

      saveSucess = await _saveMenuToFile(newMenu, editMode);

      if (saveSucess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(name + ' has been saved.'),
        ));

        if (editMode ?? false) {
          Navigator.of(context).pop(newMenu);
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SingleMenuPage(newMenu)));
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

  Future<bool> _saveMenuToFile(Menu newMenu, bool editMode) async {
    try {
      String fileContent = await fileManagement.readFile(menuJsonFile);
      List<Menu> allMenusFromFile = objManager.jsonToListMenu(fileContent);
      if (editMode ?? false) {
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
}
