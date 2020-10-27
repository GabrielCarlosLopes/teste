import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_compras/src/model/item_list.dart';
import 'package:lista_de_compras/src/pages/product_detail.dart';
import 'package:lista_de_compras/src/utils/database_helper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<ItemList> productList = List<ItemList>();
  String totalPrice = '0.0';

  ItemList _lastRemoved;

  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.shopping_cart,
            ),
            Text(
              'Total das compras: R\$$totalPrice',
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              navigateToDetail(
                ItemList('', '', '', '', ''),
              );
            },
          ),
        ],
      ),
      body: getMyList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(
            ItemList('', '', '', '', ''),
          );
        },
        tooltip: '+ 1 produto',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getMyList() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.25,
      child: ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Alert(
                  context: context,
                  title: "Preço",
                  content: Column(
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.account_circle),
                          labelText: 'Username',
                        ),
                      ),
                    ],
                  ),
                  buttons: [
                    DialogButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ]).show();
            },
            child: Card(
              elevation: 5,
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Image.asset(
                        'lib/assets/sacola_de_compras.png',
                        fit: BoxFit.cover,
                        height: 20,
                      ),
                      foregroundColor: Colors.white,
                    ),
                    title: Text(productList[index].nameProduct),
                    subtitle: Text(
                      'Quantidade: ' +
                          productList[index].amount.toString() +
                          ' ' +
                          productList[index].type +
                          ' = ' +
                          'R\$ ' +
                          productList[index].price.toString(),
                    ),
                  ),
                ),
                actions: [
                  IconSlideAction(
                    caption: 'Preço',
                    color: Colors.green,
                    icon: Icons.add,
                    onTap: () {
                      Alert(
                          context: context,
                          title: "Adicionar Preço",
                          content: Column(
                            children: <Widget>[
                              TextField(
                                controller: priceController,
                                onChanged: (value) {
                                  setState(() {
                                    _updatePrice(productList[index]);
                                    total();
                                  });
                                },
                                decoration: InputDecoration(
                                    icon: Icon(Icons.payment),
                                    labelText: 'Preço'),
                              ),
                            ],
                          ),
                          buttons: [
                            DialogButton(
                              onPressed: () {
                                _priceAtualize(productList[index]);
                                updateListView();
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Atualizar",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )
                          ]).show();
                    },
                  ),
                ],
                secondaryActions: [
                  IconSlideAction(
                    caption: 'Editar',
                    color: Colors.black45,
                    icon: Icons.more_horiz,
                    onTap: () => navigateToDetail(productList[index]),
                  ),
                  IconSlideAction(
                    caption: 'Deletar',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      setState(
                        () {
                          _lastRemoved = productList[index];
                          _delete(context, productList[index]);
                          updateListView();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void total() async {
    var total = (await _databaseHelper.getAllTotalPurchases())[0]['total'];
    setState(() {
      this.totalPrice = total.toString();
    });
  }

  void updateListView() {
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<ItemList>> itemListFuture = _databaseHelper.getItensList();
      itemListFuture.then((productList) {
        setState(() {
          total();
          this.productList = productList;
        });
      });
    });
  }

  void navigateToDetail(ItemList item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProductDetail(item);
        },
      ),
    ).then(
      (result) {
        if (result ?? true) {
          updateListView();
        }
      },
    );
  }

  void _delete(BuildContext context, ItemList item) async {
    int result = await _databaseHelper.deleteProduct(item.id);
    if (result != 0) {
      setState(
        () {
          final snack = SnackBar(
            content: Text('${_lastRemoved.nameProduct} Removida(o)'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(
                  () {
                    _reincert(_lastRemoved);
                    updateListView();
                  },
                );
              },
            ),
            duration: Duration(
              seconds: 3,
            ),
          );
          Scaffold.of(context).showSnackBar(snack);
        },
      );
    }
  }

  void _reincert(ItemList item) async {
    item.date = DateFormat.yMMMd().format(DateTime.now());

    await _databaseHelper.insertProduct(item);
  }

  void _priceAtualize(ItemList item) async {
    item.date = DateFormat.yMMMd().format(DateTime.now());

    await _databaseHelper.updateProduct(item);
  }

  void _updatePrice(ItemList item) {
    if (item.type == 'dz') {
      item.price = (double.tryParse(priceController.text)) * (item.amount * 6);
    } else {
      item.price = double.tryParse(priceController.text) * item.amount;
    }
  }
}
