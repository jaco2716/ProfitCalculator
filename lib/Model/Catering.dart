import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Meal.dart';

import 'Extra.dart';
import 'Meal.dart';
import 'Menu.dart';

class Catering {
  int id;
  String name;
  double salePrice;
  List<Ingredient> ingredients;
  List<Meal> meals;
  List<Extra> extras;
  List<Menu> menus;

  //Constructor
  Catering(this.id, this.name, this.salePrice, this.ingredients, this.meals,
      this.extras, this.menus);

  //Get the total cost of the Catering, calculated from all ingredients and meals
  double totalCost(int hourPrice) {
    double totalPrice = 0;
    ingredients?.forEach((e) {
      totalPrice += (e.amountInGrams / 1000) * e.kgPrice;
    });
    meals?.forEach((e) {
      totalPrice += e.totalCost(hourPrice) * e.amount;
    });
    extras?.forEach((e) {
      totalPrice += e.costPrice * e.amount;
    });
    menus?.forEach((e) {
      totalPrice += e.totalCost(hourPrice) * e.amount;
    });
    return totalPrice;
  }

  //Get the profit, calculated with salePrice and totalCost
  double profit(int hourPrice, int vatPercent) {
    return ((salePrice / (vatPercent / 100 + 1)) - totalCost(hourPrice));
  }

  double profitMargin(int hourPrice, int vatPercent) {
    double totalWithHour = totalCost(hourPrice);
    if (salePrice != 0 && totalCost(hourPrice) != 0) {
      double salePriceNoVat = salePrice / (vatPercent / 100 + 1);

      return ((salePriceNoVat - totalWithHour) / totalWithHour) * 100;
    } else {
      return 0;
    }
  }

  //Json convert function, fromJson and toJson
  Catering.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        salePrice = json['salePrice'],
        ingredients = (json['ingredients'] as List)
                ?.map((e) => Ingredient.fromJson(e))
                ?.toList() ??
            <Ingredient>[], //Når man konverterer en liste af objector fra Json.
        meals =
            (json['meals'] as List)?.map((e) => Meal.fromJson(e))?.toList() ??
                <Meal>[], //Når man konverterer en liste af objector fra Json.
        extras =
            (json['extras'] as List)?.map((e) => Extra.fromJson(e))?.toList() ??
                <Extra>[], //Når man konverterer en liste af objector fra Json.
        menus =
            (json['menus'] as List)?.map((e) => Menu.fromJson(e))?.toList() ??
                <Menu>[]; //Når man konverterer en liste af objector fra Json.

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'salePrice': salePrice,
        'ingredients': ingredients
            .map((e) => e.toJson())
            .toList(), //Når man konverterer en liste af objector til Json.
        'meals': meals
            .map((e) => e.toJson())
            .toList(), //Når man konverterer en liste af objector til Json.
        'extras': extras
            .map((e) => e.toJson())
            .toList(), //Når man konverterer en liste af objector til Json.
        'menus': menus
            .map((e) => e.toJson())
            .toList(), //Når man konverterer en liste af objector til Json.
      };
}
