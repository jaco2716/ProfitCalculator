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

  //Json convert, fromJson and toJson.
  Extra.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        salePrice = json['salePrice'],
        costPrice = json['buyPrice'],
        amount = json['amount'];

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
