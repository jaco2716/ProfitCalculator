class Extra {
  int id;
  String name;
  double salePrice;
  double costPrice;
  int amount;

  //Constructor
  Extra(this.id, this.name, this.salePrice, this.costPrice,
      {this.amount}); // , this.archived = false});

  //Clone the object without any refference
  Extra.clone(Extra extraCopy)
      : this(extraCopy.id, extraCopy.name, extraCopy.salePrice,
            extraCopy.costPrice,
            amount: extraCopy.amount);

  //Get the profit, calculated with salePrice and totalCost
  double profit(int vatPercent) {
    return ((salePrice / (vatPercent / 100 + 1)) - costPrice);
  }

  double profitMargin(int vatPercent) {
    if (salePrice != 0 && costPrice != 0) {
      double salePriceNoVat = salePrice / (vatPercent / 100 + 1);
      return ((salePriceNoVat - costPrice) / costPrice) * 100;
    } else {
      return 0;
    }
  }

  //Json convert, fromJson and toJson.
  Extra.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        salePrice = json['salePrice'],
        costPrice = json['buyPrice'],
        amount = json['amount'] ?? 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'salePrice': salePrice,
        'buyPrice': costPrice,
        'amount': amount,
      };

  @override
  String toString() {
    return 'Id: $id, Name: $name, salePrice: $salePrice, buyPrice: $costPrice';
  }
}
