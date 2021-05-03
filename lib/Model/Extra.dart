class Extra {
  int id;
  String name;
  double salePrice;
  double buyPrice;
  int amount;

  //Constructor
  Extra(this.id, this.name, this.salePrice, this.buyPrice,
      {this.amount}); // , this.archived = false});

  //Clone the object without any refference
  Extra.clone(Extra extraCopy)
      : this(extraCopy.id, extraCopy.name, extraCopy.salePrice,
            extraCopy.buyPrice,
            amount: extraCopy.amount);

  //Json convert, fromJson and toJson.
  Extra.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        salePrice = json['salePrice'],
        buyPrice = json['buyPrice'],
        amount = json['amount'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'salePrice': salePrice,
        'buyPrice': buyPrice,
        'amount': amount,
      };

  @override
  String toString() {
    return 'Id: $id, Name: $name, salePrice: $salePrice, buyPrice: $buyPrice';
  }
}
