import 'dart:convert';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Menu.dart';
import '../Model/Meal.dart';

class ObjectManager {

  List<Ingredient> jsonToListIngredient(String ingredientJsonSnapshot) {
    List<Ingredient> ingredients = <Ingredient>[];
    Iterable tempIngredientIterable;
    if (ingredientJsonSnapshot.length != 0) {
      tempIngredientIterable = json.decode(ingredientJsonSnapshot);
      ingredients =
          tempIngredientIterable?.map((e) => Ingredient.fromJson(e))?.toList();
    }
    return ingredients;
  }
  List<Meal> jsonToListMeal(String mealJsonSnapshot) {
    List<Meal> meals = <Meal>[];
    Iterable tempMealIterable;
    if (mealJsonSnapshot.length != 0) {
      tempMealIterable = json.decode(mealJsonSnapshot);
      meals = tempMealIterable?.map((e) => Meal.fromJson(e))?.toList();
    }
    return meals;
  }
  List<Menu> jsonToListMenu(String menuJsonSnapshot) {
    List<Menu> menus = <Menu>[];
    Iterable tempMenuIterable;
    if (menuJsonSnapshot.length != 0) {
      tempMenuIterable = json.decode(menuJsonSnapshot);
      menus = tempMenuIterable?.map((e) => Menu.fromJson(e))?.toList();
    }
    return menus;
  }
}
