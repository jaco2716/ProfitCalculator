
class Ingredient {
  int id;
  String name;
  double kgPrice;
  int color;
  String measureUnit;
  double amountInGrams;
  //bool archived;

  //Constructor
  Ingredient(this.id, this.name, this.kgPrice, this.color, this.measureUnit,
      {this.amountInGrams}); // , this.archived = false});

  //Clone the object without any refference
  Ingredient.clone(Ingredient ingredientCopy)
      : this(ingredientCopy.id, ingredientCopy.name, ingredientCopy.kgPrice,
            ingredientCopy.color, ingredientCopy.measureUnit, amountInGrams: ingredientCopy.amountInGrams);// , archived: ingredientCopy.archived);

  //Json convert, fromJson and toJson.
  Ingredient.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        kgPrice = json['kgPrice'],
        color = json['color'],
        measureUnit = json['measureUnit'],
        amountInGrams = json['amountInGrams'];
        // archived = json['archived'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kgPrice': kgPrice,
        'color': color,
        'measureUnit': measureUnit,
        'amountInGrams': amountInGrams,
        // 'archived': archived,
      };

      @override
  String toString() {
    
    return 'Id: $id, Name: $name, kgPrice: $kgPrice, color: $color, measureUnit: $measureUnit, amountInGrams: $amountInGrams';
  }
}
