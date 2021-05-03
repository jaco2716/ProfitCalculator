import 'package:profit_calculator/Model/Ingredient.dart';
import 'package:profit_calculator/Model/Meal.dart';

import 'Meal.dart';

class Menu {
  int id;
  String name;
  double salePrice;
  List<Ingredient> ingredients;
  List<Meal> meals;

  //Constructor
  Menu(this.id, this.name, this.salePrice, this.ingredients, this.meals);

  //Get the total cost of the menu, calculated from all ingredients and meals
  double get totalCost {
    double totalPrice = 0;
    ingredients?.forEach((e) {
      if (e.measureUnit == 'ml' || e.measureUnit == 'g') {
        totalPrice += (e.amountInGrams) * e.kgPrice;
      } else
        totalPrice += (e.amountInGrams / 1000) * e.kgPrice;
    });
    meals?.forEach((e) {
      totalPrice += e.totalCost * e.amount;
    });
    return totalPrice;
  }

  int get totalMinutesToMake {
    int totalMinutes = 0;
    meals?.forEach((e) {
      totalMinutes += e.minutesToMake * e.amount;
    });
    return totalMinutes;
  }

  //Get the profit, calculated with salePrice and totalCost
  double get profit {
    return (salePrice - totalCost);
  }

  double profitMargin(int hourPrice) {
    if (salePrice != 0 && totalCost != 0) {
      double totalWithHour = totalCost + ((hourPrice / 60) * totalMinutesToMake);

      return ((salePrice - totalWithHour) / totalWithHour) * 100;
    } else {
      return 0;
    }
  }
  // double get profitMargin {
  //   if (salePrice != 0 && totalCost != 0) {
  //     return ((salePrice - totalCost) / totalCost) * 100;
  //   } else {
  //     return 0;
  //   }
  // }

  // double get profitMargin {
  //   if (salePrice != 0) {
  //     return (profit / salePrice * 100);
  //   } else
  //     return 0;
  // }

  //Json convert function, fromJson and toJson
  Menu.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        salePrice = json['salePrice'],
        ingredients = (json['ingredients'] as List)
            ?.map((e) => Ingredient.fromJson(e))
            ?.toList(), //Når man konverterer en liste af objector fra Json.
        meals = (json['meals'] as List)
            ?.map((e) => Meal.fromJson(e))
            ?.toList(); //Når man konverterer en liste af objector fra Json.

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
      };
}
