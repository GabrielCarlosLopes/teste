class ItemList {
  int _id;
  String _nameProduct;
  int _amount;
  String _type;
  String _date;
  double _price;

  ItemList(_nameProduct, _amount, _type, _date, _price);

  ItemList.witchId(_id, _nameProduct, _amount, _type, _date, _price);

  int get id => _id;

  String get nameProduct => _nameProduct;

  String get date => _date;

  int get amount => _amount;

  String get type => _type;

  double get price => _price;

  set nameProduct(String newNameProduct) {
    if (newNameProduct.length <= 255) {
      this._nameProduct = newNameProduct;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set amount(int newAmount) {
    this._amount = newAmount;
  }

  set type(String newType){
    this._type = newType;
  }

  set price(double newPrice){
    this._price = newPrice;
  }
  

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['nameProduct'] = _nameProduct;
    map['amount'] = _amount;
    map['type'] = _type;
    map['date'] = _date;
    map['price'] = _price;

    return map;
  }

  ItemList.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._nameProduct = map['nameProduct'];
    this._amount = map['amount'];
    this._type = map['type'];
    this._date = map['date'];
    this._price = map['price'];
  }


}
