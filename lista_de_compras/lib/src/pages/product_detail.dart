import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_compras/src/model/item_list.dart';
import 'package:lista_de_compras/src/utils/database_helper.dart';

class ProductDetail extends StatefulWidget {
  final ItemList item;

  ProductDetail(this.item);

  @override
  _ProductDetailState createState() {
    return _ProductDetailState(this.item);
  }
}

class _ProductDetailState extends State<ProductDetail> {
  DatabaseHelper helper = DatabaseHelper();

  ItemList item;
  String dropdownValue = 'un';
  double price = 0.0;

  TextEditingController productNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _ProductDetailState(this.item);

  @override
  void initState() {
    super.initState();
    dropdownValue = item.type == null ? 'un' : item.type;
    price = item.price == null ? 0.0 : item.price;
    _updateType();
    _updatePrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            item.nameProduct == null ? 'Adicionar' : item.nameProduct,
          ),
        ),
        body: _form());
  }

  void _updateProductName() {
    item.nameProduct = productNameController.text;
  }

  void _updateAmount() {
    item.amount = int.tryParse(amountController.text);
    if (item.type == 'dz') {
      item.price = price * (item.amount * 6);
    } else {
      item.price = price * item.amount;
    }
  }

  void _updateType() {
    item.type = dropdownValue.toString();
  }

  void _updatePrice() {
    item.price = price;
  }

  void _save() async {
    Navigator.pop(context);

    item.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (item.id != null) {
      // Caso 1: Atualizar
      result = await helper.updateProduct(item);
    } else {
      // Caso 2: Inserir
      result = await helper.insertProduct(item);
    }

    if (result != 0) {
      // Succeso
      _showAlertDialog('Status', 'Salvo com sucesso');
    } else {
      // deu merda
      _showAlertDialog('Status', 'Eita nóis');
    }
  }


  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Widget _buttonType() {
    return DropdownButton<String>(
      value: dropdownValue,
      iconSize: 24,
      iconEnabledColor: Colors.deepPurple,
      elevation: 16,
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
          _updateType();
        });
      },
      items: <String>[
        'un',
        'dz',
        'ml',
        'L',
        'kg',
        'g',
        'Caixa',
        'Embalagem',
        'Galão',
        'Garrafa',
        'Lata',
        'Pacote',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _saveButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text(
              'Salvar',
              textScaleFactor: 1.5,
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                setState(
                  () {
                    _save();
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ListView(
          children: [
            TextFormField(
              controller: productNameController,
              onChanged: (value) {
                _updateProductName();
              },
              decoration: InputDecoration(
                labelText:
                    item.nameProduct == null ? 'Produto' : item.nameProduct,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Por favor digite o nome do produto';
                }
                return null;
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: amountController,
              onChanged: (value) {
                _updateAmount();
              },
              decoration: InputDecoration(
                labelText:
                    item.amount == null ? 'Quantidade' : item.amount.toString(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Por favor coloque uma quantidade';
                }
                return null;
              },
            ),
            _buttonType(),
            SizedBox(
              height: 20,
            ),
            _saveButton()
          ],
        ),
      ),
    );
  }
}
