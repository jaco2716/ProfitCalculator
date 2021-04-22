import 'dart:convert';
import 'package:profit_calculator/Model/Ingredient.dart';
import '../Model/Meal.dart';

class ObjectManager {
  List<Meal> jsonToListMeal(String mealJsonSnapshot) {
    List<Meal> meals = <Meal>[];
    Iterable tempMealIterable;
    if (mealJsonSnapshot.length != 0) {
      tempMealIterable = json.decode(mealJsonSnapshot);
      meals = tempMealIterable?.map((e) => Meal.fromJson(e))?.toList();
    }
    return meals;
  }

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
}
