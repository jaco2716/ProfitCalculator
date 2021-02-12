import 'dart:convert';
import 'package:profit_calculator/Model/Ingredient.dart';
import 'Model/Meal.dart';

class ObjectManager {
  List<Meal> jsonToListMeal(String mealJsonSnapshot) {
    Iterable tempMealIterable = json.decode(mealJsonSnapshot);
    List<Meal> meals = List<Meal>();
    meals = tempMealIterable?.map((e) => Meal.fromJson(e))?.toList();
    return meals;
  }
  
  List<Ingredient> jsonToListIngredient(String ingredientJsonSnapshot) {
    Iterable tempIngredientIterable = json.decode(ingredientJsonSnapshot);
    List<Ingredient> ingredients = List<Ingredient>();
    ingredients = tempIngredientIterable?.map((e) => Ingredient.fromJson(e))?.toList();
    return ingredients;
  }

}
