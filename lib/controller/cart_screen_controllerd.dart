import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class CartScreenController with ChangeNotifier {
  static late Database database;
  List<Map> cartItems = [];
  double totalPrice = 0.0;


  static Future<void> initDb() async {
    if (kIsWeb) {
      // Change default factory on the web
      databaseFactory = databaseFactoryFfiWeb;
    }

    database = await openDatabase(
      "cart.db",
      version: 1,
      onCreate: (db, version) async {
        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE Cart (id INTEGER PRIMARY KEY, name TEXT, qty INTEGER, price REAL, image TEXT, des TEXT, productId INTEGER)');
      },
    );
  }

  Future addItem({
    bool alreadyAdded = false,
    required int productId,
    required String name,
    required String des,
    required String imgurl,
    required double price,
  }) async {
     await getAllItems();
    for (int i = 0;i<cartItems.length;i++){
      if(cartItems[i]["productId"]==productId){

         alreadyAdded = true;                                                                                                     
      }
    }
    if (alreadyAdded ==false ){await database.rawInsert(
        'INSERT INTO Cart(name, qty, price, image, des, productId) VALUES(?, ?, ?, ?, ?, ?)',
        [name, 1, price, imgurl, des, productId]);
        // snap
        }
  }

  Future getAllItems() async {
    cartItems = await database.rawQuery('SELECT * FROM Cart');
    log(cartItems.toString());
    notifyListeners();
  }

  removeAnItem(int id) async {
    await database.rawDelete('DELETE FROM Test WHERE name = ?', [id]);
    getAllItems();
    notifyListeners();
  }
  


  Future <void> decrementQty(int qty,int id) async {
    if(qty>=2){
      qty--;
     await database.rawUpdate('UPDATE Cart SET qty = ? WHERE id = ?',
  [qty,id]);
  await getAllItems();
    }
  }

  Future <void> incrementQty(int qty,int id) async {
      qty++;
    await  database.rawUpdate('UPDATE Cart SET qty = ? WHERE id = ?',
  [qty,id]);
 await getAllItems();
  }
  
  void calculateTotal(){
    totalPrice = 0.0;
    for(int i=0;i<cartItems.length;i++ ){
      double currentItemPrice = cartItems[i]['price']*cartItems[i]['qty'];
      totalPrice = totalPrice + currentItemPrice;
    }
    notifyListeners();
  }

}
