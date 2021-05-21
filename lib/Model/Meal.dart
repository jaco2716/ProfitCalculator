import 'package:profit_calculator/Model/Ingredient.dart';

class Meal {
  int id;
  String name;
  double salePrice;
  List<Ingredient> ingredients;
  int minutesToMake;
  int amount;

  //Constructor
  Meal(this.id, this.name, this.salePrice, this.ingredients, this.minutesToMake,
      {this.amount});

  Meal.clone(Meal mealCopy)
      : this(mealCopy.id, mealCopy.name, mealCopy.salePrice,
            mealCopy.ingredients, mealCopy.minutesToMake,
            amount: mealCopy.amount);

  //Get the total cost of the meal, calculated from all ingredients
  double totalCost(int hourPrice) {
    double totalPrice = 0;
    ingredients?.forEach((e) {
        totalPrice += (e.amountInGrams / 1000) * e.kgPrice;
    });
    totalPrice += (hourPrice / 60) * minutesToMake;
    return totalPrice;
  }

  //Get the profit, calculated with salePrice and totalCost
  double profit(int hourPrice, int vatPercent) {
    return ((salePrice / (vatPercent / 100 + 1)) - totalCost(hourPrice));
  }

  double profitMargin(int hourPrice, int vatPercent) {
    double totalWithHour = totalCost(hourPrice);
    if (salePrice != 0 && totalWithHour != 0) {
      // double totalWithHour = totalCost + ((hourPrice / 60) * minutesToMake);
      double salePriceNoVat = salePrice / (vatPercent / 100 + 1);

      return ((salePriceNoVat - totalWithHour) / totalWithHour) * 100;
    } else {
      return 0;
    }
  }
  // double get profitMargin {
  //   if (salePrice != 0) {
  //     return (profit / salePrice * 100);
  //   } else {
  //     return 0;
  //   }
  // }

  //Json convert function, fromJson and toJson
  Meal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        salePrice = json['salePrice'],
        ingredients = (json['ingredients'] as List)
            ?.map((e) => Ingredient.fromJson(e))
            ?.toList()?? <Ingredient>[], //Når man konverterer en liste af objector fra Json.
        minutesToMake = json['minutesToMake'],
        amount = json['amount'] ?? 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'salePrice': salePrice,
        'ingredients': ingredients
            .map((e) => e.toJson())
            .toList(), //Når man konverterer en liste af objector til Json.
        'minutesToMake': minutesToMake,
        'amount': amount,
      };
}
